import BSON
import MongoDB
import UnidocRecords

extension Unidoc.DB
{
    @frozen public
    struct PackageBuilds
    {
        public
        let database:Mongo.Database

        @inlinable internal
        init(database:Mongo.Database)
        {
            self.database = database
        }
    }
}
extension Unidoc.DB.PackageBuilds
{
    public static
    let indexQueue:Mongo.CollectionIndex = .init("Queued", unique: false)
    {
        $0[Unidoc.BuildMetadata[.request]] = (+)
    }
        where:
    {
        $0[Unidoc.BuildMetadata[.request]] { $0[.exists] = true }
    }

    public static
    let indexStarted:Mongo.CollectionIndex = .init("Started", unique: false)
    {
        $0[Unidoc.BuildMetadata[.progress] / Unidoc.BuildProgress[.started]] = (+)
    }
        where:
    {
        $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = true }
    }
}
extension Unidoc.DB.PackageBuilds:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.BuildMetadata

    @inlinable public static
    var name:Mongo.Collection { "Builds" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexQueue,
            Self.indexStarted,
        ]
    }
}
extension Unidoc.DB.PackageBuilds
{
    public
    func selectBuild(with session:Mongo.Session) async throws -> Unidoc.BuildMetadata?
    {
        //  Find a build, any build...
        if  let build:Unidoc.BuildMetadata = try await session.run(
            command: Mongo.Find<Mongo.Single<Unidoc.BuildMetadata>>.init(Self.name, limit: 1)
            {
                $0[.hint] = Self.indexQueue.id
                $0[.filter]
                {
                    $0[Unidoc.BuildMetadata[.request]] { $0[.exists] = true }
                }
            },
            against: self.database)
        {
            return build
        }

        let startTime:BSON.Timestamp? = session.preconditionTime

        //  Open a change stream and wait for a build to be enqueued...
        typealias ChangeEvent = Mongo.ChangeEvent<Unidoc.BuildMetadata,
            Mongo.ChangeUpdate<Unidoc.BuildMetadataDelta, Unidoc.Package>>

        defer
        {
            print("Cancelling change stream...")
        }

        return try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<ChangeEvent>>.init(Self.name,
                tailing: .init(timeout: 5_000, awaits: true))
            {
                $0[stage: .changeStream]
                {
                    //  This prevents us from missing any builds enqueued between when we ran
                    //  the find query and when we open the change stream.
                    $0[.startAtOperationTime] = startTime
                }
                //  TODO: filter change events
            },
            against: self.database)
        {
            for try await events:[ChangeEvent] in $0
            {
                for event:ChangeEvent in events
                {
                    switch event.operation
                    {
                    case .replace(_, before: _, after: let build):  return build
                    case .insert(let build):                        return build
                    default:                                        continue
                    }
                }
            }

            return nil
        }
    }

    public
    func submitBuild(
        request:Unidoc.BuildRequest,
        package:Unidoc.Package,
        with session:Mongo.Session) async throws
    {
        do
        {
            let (_, _):(Unidoc.BuildMetadata?, Unidoc.Package?) = try await session.run(
                command: Mongo.FindAndModify<Mongo.Upserting<
                    Unidoc.BuildMetadata,
                    Unidoc.Package>>.init(Self.name,
                    returning: .new)
                {
                    $0[.query]
                    {
                        $0[Unidoc.BuildMetadata[.id]] = package
                        $0[Unidoc.BuildMetadata[.request]] { $0[.exists] = false }
                        $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = false }
                    }
                    $0[.update] = Unidoc.BuildMetadata.init(id: package, request: request)
                },
                against: self.database)
        }
        catch let error
        {
            //  TODO: catch duplicate key error
            print(error)
            return
        }
    }

    public
    func assignBuild(
        request:Unidoc.BuildRequest,
        package:Unidoc.Package,
        builder:Unidoc.Account,
        with session:Mongo.Session) async throws -> Bool
    {
        let (update, _):(Unidoc.BuildMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.BuildMetadata>>.init(Self.name,
                returning: .new)
            {
                $0[.query]
                {
                    $0[Unidoc.BuildMetadata[.id]] = package
                    $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = false }
                }
                $0[.update]
                {
                    $0[.unset]
                    {
                        $0[Unidoc.BuildMetadata[.request]] = ()
                    }
                    $0[.set]
                    {
                        $0[Unidoc.BuildMetadata[.progress]] = Unidoc.BuildProgress.init(
                            started: .now(),
                            request: request,
                            builder: builder)
                    }
                }
            },
            against: self.database)

        return update != nil
    }

    public
    func finishBuild(
        package:Unidoc.Package,
        with session:Mongo.Session) async throws -> Mongo.Deletions?
    {
        let deleted:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.One>.init(Self.name)
            {
                $0
                {
                    $0[.q]
                    {
                        $0[Unidoc.BuildMetadata[.id]] = package
                        $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = true }
                    }
                    $0[.limit] = .one
                }
            },
            against: self.database)

        return try deleted.deletions()
    }

    public
    func lintBuild(startedBefore:BSON.Millisecond,
        with session:Mongo.Session) async throws -> Unidoc.BuildMetadata?
    {
        let (status, _):(Unidoc.BuildMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.BuildMetadata>>.init(Self.name,
                returning: .old)
            {
                $0[.query]
                {
                    $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = true }
                    $0[Unidoc.BuildMetadata[.progress] / Unidoc.BuildProgress[.started]]
                    {
                        $0[.lt] = startedBefore
                    }
                }
                $0[.update]
                {
                    $0[.unset]
                    {
                        $0[Unidoc.BuildMetadata[.progress]] = ()
                    }
                    $0[.set]
                    {
                        $0[Unidoc.BuildMetadata[.failure]] = Unidoc.BuildOutcome.Failure.init(
                            reason: .timeout)
                    }
                }
            },
            against: self.database)

        return status
    }
}
