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
        let request:Unidoc.Edition

        private
        let producer:CheckedContinuation<Void, any Error>
        private
        let producerAwaiting:ManagedAtomic<Bool>

        init(appeared:BSON.Timestamp,
            request:Unidoc.Edition,
            producer:CheckedContinuation<Void, any Error>)
        {
            self.appeared = appeared
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
        in database:Unidoc.Database,
        registrar:any Unidoc.Registrar) async -> Unidoc.BuildCoordinator.Subscription?
    {
        let labels:Unidoc.BuildLabels?
        do
        {
            labels = try await self.match(with: subscription.assignee,
                in: database,
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
        in database:Unidoc.Database,
        registrar:any Unidoc.Registrar) async throws -> Unidoc.BuildLabels?
    {
        let db:Unidoc.DB = try await database.session()

        //  We need to ensure we are querying the state of the database *after* we received the
        //  original notification, so that we do not experience reversed ordering.
        db.session.synchronize(to: self.appeared)

        guard try await db.pendingBuilds.assignBuild(id: self.request, to: assignee)
        else
        {
            //  The build request no longer exists in the database, perhaps because it was
            //  cancelled or manually deleted. This isn’t really an error, but we do need to
            //  unblock the producer.
            return nil
        }

        if  let ref:Unidoc.RefState = try await db.ref(of: .id(self.request)),
            let labels:Unidoc.BuildLabels = try await registrar.resolve(ref, rebuild: true)
        {
            return labels
        }
        else
        {
            /// Either the edition or the package, or both, no longer exist.
            let _:Bool = try await db.pendingBuilds.cancelBuild(id: self.request)
            return nil
        }
    }
}
