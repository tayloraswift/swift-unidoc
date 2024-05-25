import BSON
import MongoDB
import UnidocAPI
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
        $0[Unidoc.BuildMetadata[.selector]] = (+)
    }
        where:
    {
        $0[Unidoc.BuildMetadata[.selector]] { $0[.exists] = true }
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
    func selectBuild(await awaits:Bool,
        with session:Mongo.Session) async throws -> Unidoc.BuildMetadata?
    {
        //  Find a build, any build...
        if  let build:Unidoc.BuildMetadata = try await session.run(
            command: Mongo.Find<Mongo.Single<Unidoc.BuildMetadata>>.init(Self.name, limit: 1)
            {
                $0[.hint] = Self.indexQueue.id
                $0[.filter]
                {
                    $0[Unidoc.BuildMetadata[.selector]] { $0[.exists] = true }
                }
            },
            against: self.database)
        {
            return build
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
                Unidoc.BuildMetadataDelta>>>.init(Self.name,
                tailing: .init(timeout: 30_000, awaits: true))
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
            for try await events:[Mongo.ChangeEvent<Unidoc.BuildMetadataDelta>] in $0
            {
                for event:Mongo.ChangeEvent<Unidoc.BuildMetadataDelta> in events
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

    public
    func submitBuild(
        request:Unidoc.BuildRequest,
        package:Unidoc.Package,
        with session:Mongo.Session) async throws -> Bool
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
                        $0[Unidoc.BuildMetadata[.selector]] { $0[.exists] = false }
                        $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = false }
                    }
                    $0[.update] = Unidoc.BuildMetadata.init(id: package, request: request)
                },
                against: self.database)

            return true
        }
        catch let error as Mongo.ServerError
        {
            //  Duplicate key error
            guard case 11000 = error.code
            else
            {
                throw error
            }

            return false
        }
    }

    public
    func cancelBuild(
        package:Unidoc.Package,
        with session:Mongo.Session) async throws -> Bool
    {
        let deleted:Mongo.DeleteResponse = try await session.run(
            command: Mongo.Delete<Mongo.One>.init(Self.name)
            {
                $0
                {
                    $0[.q]
                    {
                        $0[Unidoc.BuildMetadata[.id]] = package
                        $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = false }
                    }
                    $0[.limit] = .one
                }
            },
            against: self.database)

        let deletions:Mongo.Deletions = try deleted.deletions()
        return deletions.deleted != 0
    }

    public
    func assignBuild(
        request:Unidoc.BuildSelector,
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
                        $0[Unidoc.BuildMetadata[.selector]] = ()
                    }
                    $0[.set]
                    {
                        $0[Unidoc.BuildMetadata[.progress]] = Unidoc.BuildProgress.init(
                            started: .now(),
                            builder: builder,
                            request: request,
                            stage: .initializing)
                    }
                }
            },
            against: self.database)

        return update != nil
    }

    @discardableResult
    public
    func updateBuild(
        package:Unidoc.Package,
        entered:Unidoc.BuildStage,
        with session:Mongo.Session) async throws -> Unidoc.BuildMetadata?
    {
        let (status, _):(Unidoc.BuildMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.BuildMetadata>>.init(Self.name,
                returning: .old)
            {
                $0[.query]
                {
                    //  We must only write to build metadata that already contain `progress`,
                    //  otherwise we may generate undecodable structures!
                    $0[Unidoc.BuildMetadata[.id]] = package
                    $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = true }
                }
                $0[.update]
                {
                    $0[.set]
                    {
                        $0[ Unidoc.BuildMetadata[.progress] /
                            Unidoc.BuildProgress[.stage]] = entered
                    }
                }
            },
            against: self.database)

        return status
    }

    @discardableResult
    public
    func finishBuild(
        package:Unidoc.Package,
        failure:Unidoc.BuildFailure? = nil,
        logs:[Unidoc.BuildLogType]? = nil,
        with session:Mongo.Session) async throws -> Unidoc.BuildMetadata?
    {
        let (status, _):(Unidoc.BuildMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.BuildMetadata>>.init(Self.name,
                returning: .old)
            {
                $0[.query]
                {
                    $0[Unidoc.BuildMetadata[.id]] = package
                }
                $0[.update]
                {
                    if  let failure:Unidoc.BuildFailure
                    {
                        $0[.set]
                        {
                            $0[Unidoc.BuildMetadata[.failure]] = failure
                            $0[Unidoc.BuildMetadata[.logs]] = logs
                        }
                        $0[.unset]
                        {
                            $0[Unidoc.BuildMetadata[.progress]] = ()
                        }
                    }
                    else
                    {
                        $0[.set]
                        {
                            $0[Unidoc.BuildMetadata[.logs]] = logs
                        }
                        $0[.unset]
                        {
                            $0[Unidoc.BuildMetadata[.progress]] = ()
                            $0[Unidoc.BuildMetadata[.failure]] = ()
                        }
                    }
                }
            },
            against: self.database)

        return status
    }

    public
    func lintBuilds(startedBefore:BSON.Millisecond,
        with session:Mongo.Session) async throws -> Int
    {
        let failure:Unidoc.BuildFailure = .timeout
        let response:Mongo.UpdateResponse = try await session.run(
            command: Mongo.Update<Mongo.Many, Unidoc.Package>.init(Self.name)
            {
                $0
                {
                    $0[.multi] = true
                    $0[.q]
                    {
                        $0[Unidoc.BuildMetadata[.progress]] { $0[.exists] = true }
                        $0[Unidoc.BuildMetadata[.progress] / Unidoc.BuildProgress[.started]]
                        {
                            $0[.lt] = startedBefore
                        }
                    }
                    $0[.u]
                    {
                        $0[.unset]
                        {
                            $0[Unidoc.BuildMetadata[.progress]] = ()
                        }
                        $0[.set]
                        {
                            $0[Unidoc.BuildMetadata[.failure]] = failure
                        }
                    }
                }
            },
            against: self.database)

        let updates:Mongo.Updates = try response.updates()
        return updates.selected
    }
}
