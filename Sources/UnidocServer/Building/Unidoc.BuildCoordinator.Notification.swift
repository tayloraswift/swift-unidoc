import Atomics
import BSON
import MongoDB

extension Unidoc.BuildCoordinator
{
    final
    class Notification:Sendable
    {
        private
        let appeared:BSON.Timestamp
        private
        let package:Unidoc.Package
        private
        let request:Unidoc.BuildRequest<Void>

        private
        let producer:CheckedContinuation<Void, any Error>
        private
        let producerAwaiting:ManagedAtomic<Bool>

        init(appeared:BSON.Timestamp,
            package:Unidoc.Package,
            request:Unidoc.BuildRequest<Void>,
            producer:CheckedContinuation<Void, any Error>)
        {
            self.appeared = appeared
            self.package = package
            self.request = request
            self.producer = producer
            self.producerAwaiting = .init(true)
        }

        private
        func clear()
        {
            if  self.producerAwaiting.exchange(false, ordering: .relaxed)
            {
                self.producer.resume()
            }
        }

        private
        func clear(throwing error:any Error)
        {
            if  self.producerAwaiting.exchange(false, ordering: .relaxed)
            {
                self.producer.resume(throwing: error)
            }
        }

        deinit
        {
            if  self.producerAwaiting.exchange(false, ordering: .relaxed)
            {
                self.producer.resume(
                    throwing: Unidoc.BuildCoordinatorAssertionError.droppedNotification)
            }
        }
    }
}
extension Unidoc.BuildCoordinator.Notification
{
    func match(with subscription:__owned Unidoc.BuildCoordinator.Subscription,
        in db:Unidoc.Database,
        registrar:any Unidoc.Registrar) async -> Unidoc.BuildCoordinator.Subscription?
    {
        let labels:Unidoc.BuildLabels?
        do
        {
            labels = try await self.match(with: subscription.assignee,
                in: db,
                registrar: registrar)
        }
        catch let error
        {
            self.clear(throwing: error)
            return subscription
        }

        guard
        let labels:Unidoc.BuildLabels
        else
        {
            self.clear()
            return subscription
        }

        if  let _:Unidoc.BuildLabels = subscription.resume(returning: labels)
        {
            self.clear(throwing: Unidoc.BuildCoordinatorAssertionError.overusedSubscription)
            return nil
        }
        else
        {
            self.clear()
            return nil
        }
    }

    private
    func match(with assignee:Unidoc.Account,
        in db:Unidoc.Database,
        registrar:any Unidoc.Registrar) async throws -> Unidoc.BuildLabels?
    {
        let session:Mongo.Session = try await .init(from: db.sessions)

        //  We need to ensure we are querying the state of the database *after* we received the
        //  original notification, so that we do not experience reversed ordering.
        session.synchronize(to: self.appeared)

        guard try await db.packageBuilds.assignBuild(
            request: self.request.behavior,
            package: self.package,
            builder: assignee,
            with: session)
        else
        {
            //  The build request no longer exists in the database, perhaps because it was
            //  cancelled or manually deleted. This isn’t really an error, but we do need to
            //  unblock the producer.
            return nil
        }

        let version:Unidoc.BuildSelector<Unidoc.Package>

        switch self.request.version
        {
        case .latest(let series, of: ()):   version = .latest(series, of: self.package)
        case .id(let id):                   version = .id(id)
        }

        if  let edition:Unidoc.EditionState = try await db.unidoc.editionState(of: version,
                with: session),
            let labels:Unidoc.BuildLabels = try await registrar.resolve(edition,
                rebuild: self.request.rebuild)
        {
            return labels
        }
        else
        {
            /// We don’t really care if something else raced us here.
            let _:Unidoc.BuildMetadata? = try await db.packageBuilds.finishBuild(
                package: self.package,
                failure: .noValidVersion,
                with: session)
            return nil
        }
    }
}
