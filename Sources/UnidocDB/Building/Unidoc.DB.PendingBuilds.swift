import BSON
import MongoDB
import Symbols
import UnidocAPI
import UnidocRecords
import UnixTime

extension Unidoc.DB
{
    @frozen public
    struct PendingBuilds
    {
        public
        let database:Mongo.Database
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.PendingBuilds
{
    public static
    let indexEnqueued:Mongo.CollectionIndex = .init("Enqueued", unique: false)
    {
        $0[Unidoc.PendingBuild[.enqueued]] = (+)
    }
        where:
    {
        $0[Unidoc.PendingBuild[.enqueued]] { $0[.exists] = true }
    }

    public static
    let indexLaunched:Mongo.CollectionIndex = .init("Launched", unique: false)
    {
        $0[Unidoc.PendingBuild[.launched]] = (+)
    }
        where:
    {
        $0[Unidoc.PendingBuild[.launched]] { $0[.exists] = true }
    }

    public static
    let indexPackage:Mongo.CollectionIndex = .init("Package", unique: false)
    {
        $0[Unidoc.PendingBuild[.package]] = (+)
    }
}
extension Unidoc.DB.PendingBuilds:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.PendingBuild

    @inlinable public static
    var name:Mongo.Collection { "PendingBuilds" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexEnqueued,
            Self.indexLaunched,
            Self.indexPackage
        ]
    }
}
extension Unidoc.DB.PendingBuilds
{
    public
    func selectBuild(await awaits:Bool) async throws -> Unidoc.PendingBuild?
    {
        //  Find a build, any build...
        if  let pendingBuild:Unidoc.PendingBuild = try await session.run(
                command: Mongo.Find<Mongo.Single<Unidoc.PendingBuild>>.init(Self.name, limit: 1)
                {
                    $0[.filter]
                    {
                        $0[Unidoc.PendingBuild[.enqueued]] { $0[.exists] = true }
                    }
                    $0[.sort]
                    {
                        $0[Unidoc.PendingBuild[.enqueued]] = (+)
                    }
                    $0[.hint] = Self.indexEnqueued.id
                },
                against: self.database)
        {
            return pendingBuild
        }

        guard awaits
        else
        {
            return nil
        }

        let startTime:BSON.Timestamp? = session.preconditionTime

        //  Open a change stream and wait for a build to be enqueued...
        return try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<Mongo.ChangeEvent<
                Unidoc.PendingBuildDelta>>>.init(Self.name,
                tailing: .init(timeout: .milliseconds(30_000), awaits: true))
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
            for try await events:[Mongo.ChangeEvent<Unidoc.PendingBuildDelta>] in $0
            {
                for event:Mongo.ChangeEvent<Unidoc.PendingBuildDelta> in events
                {
                    switch event.change
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

    /// Adds a build to the queue, if it is not already queued, or returns the existing build.
    public
    func submitBuild(id:Unidoc.Edition,
        name:Symbol.PackageAtRef) async throws -> Unidoc.PendingBuild
    {
        let (pendingBuild, _):(Unidoc.PendingBuild, Bool) = try await self.modify(
            upserting: id,
            returning: .new)
        {
            let now:UnixMillisecond = .now()

            $0[.setOnInsert] = Unidoc.PendingBuild.init(id: id,
                run: now,
                enqueued: now,
                launched: nil,
                assignee: nil,
                stage: nil,
                name: name)
        }
        return pendingBuild
    }

    /// Cancels a build, if it has not yet been launched.
    public
    func cancelBuild(id:Unidoc.Edition) async throws -> Bool
    {
        try await self.delete
        {
            $0[Unidoc.PendingBuild[.id]] = id
            $0[Unidoc.PendingBuild[.launched]] { $0[.exists] = false }
        }
    }

    public
    func assignBuild(id:Unidoc.Edition, to assignee:Unidoc.Account) async throws -> Bool
    {
        let (update, _):(Unidoc.PendingBuild?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.PendingBuild>>.init(Self.name,
                returning: .new)
            {
                $0[.query]
                {
                    $0[Unidoc.PendingBuild[.id]] = id
                    $0[Unidoc.PendingBuild[.assignee]] { $0[.exists] = false }
                }
                $0[.update]
                {
                    $0[.unset]
                    {
                        $0[Unidoc.PendingBuild[.enqueued]] = ()
                    }
                    $0[.set]
                    {
                        $0[Unidoc.PendingBuild[.assignee]] = assignee
                        $0[Unidoc.PendingBuild[.launched]] = UnixMillisecond.now()
                        $0[Unidoc.PendingBuild[.stage]] = Unidoc.BuildStage.initializing
                    }
                }
            },
            against: self.database)

        return update != nil
    }

    @discardableResult
    public
    func updateBuild(id:Unidoc.Edition,
        entered stage:Unidoc.BuildStage) async throws -> Unidoc.PendingBuild?
    {
        try await self.modify(existing: id, returning: .new)
        {
            $0[.set] { $0[Unidoc.PendingBuild[.stage]] = stage }
        }
    }

    public
    func finishBuild(id:Unidoc.Edition) async throws -> Unidoc.PendingBuild?
    {
        try await self.remove
        {
            $0[Unidoc.PendingBuild[.id]] = id
            $0[Unidoc.PendingBuild[.launched]] { $0[.exists] = true }
        }
    }

    public
    func lintBuilds(startedBefore:UnixMillisecond) async throws -> Int
    {
        try await self.deleteAll
        {
            $0[Unidoc.PendingBuild[.launched]] { $0[.exists] = true }
            $0[Unidoc.PendingBuild[.launched]] { $0[.lt] = startedBefore }
        }
    }

    public
    func killBuilds(by assignee:Unidoc.Account) async throws -> Int
    {
        try await self.deleteAll
        {
            $0[Unidoc.PendingBuild[.launched]] { $0[.exists] = true }
            $0[Unidoc.PendingBuild[.assignee]] = assignee
        }
    }
}