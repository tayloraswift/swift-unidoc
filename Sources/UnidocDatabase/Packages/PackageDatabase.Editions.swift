import BSON
import GitHubIntegration
import JSONEncoding
import MongoDB
import SHA1
import UnidocAnalysis
import UnidocRecords

extension PackageDatabase
{
    @frozen public
    struct Editions
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
extension PackageDatabase.Editions:DatabaseCollection
{
    public
    typealias ElementID = Unidoc.Zone

    @inlinable public static
    var name:Mongo.Collection { "editions" }

    public static
    let indexes:[Mongo.CreateIndexStatement] =
    [
        .init
        {
            $0[.unique] = true
            $0[.name] = "package,name"
            $0[.key] = .init
            {
                $0[PackageEdition[.package]] = (+)
                $0[PackageEdition[.name]] = (+)
            }
        },
        .init
        {
            $0[.unique] = true
            $0[.name] = "package,version"
            $0[.key] = .init
            {
                $0[PackageEdition[.package]] = (-)
                $0[PackageEdition[.version]] = (-)
            }
        },
    ]
}
extension PackageDatabase.Editions
{
    /// Returns the identifiers of all the documents in this collection.
    func list(with session:Mongo.Session) async throws -> [Unidoc.Zone]
    {
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Mongo.IdentityView<Unidoc.Zone>>>.init(Self.name,
                stride: 4096,
                limit: .max)
            {
                $0[.projection] = .init
                {
                    $0[PackageEdition[.id]] = true
                }
            },
            against: self.database)
        {
            try await $0.reduce(into: [])
            {
                for view:Mongo.IdentityView<Unidoc.Zone> in $1
                {
                    $0.append(view.id)
                }
            }
        }
    }
}
extension PackageDatabase.Editions
{
    public
    func register(_ tag:__owned GitHubAPI.Tag,
        package:Int32,
        with session:Mongo.Session) async throws -> Int32?
    {
        let allocation:Placement = try await self.register(package: package,
            refname: tag.name,
            sha1: tag.hash,
            with: session)

        return allocation.sha1 == nil ? allocation.cell : nil
    }

    func register(
        package:Int32,
        refname:String,
        sha1:SHA1,
        with session:Mongo.Session) async throws -> Placement
    {
        let placement:Placement = try await self.place(
            package: package,
            refname: refname,
            with: session)

        let edition:Unidoc.Zone = .init(package: package, version: placement.cell)

        switch placement.sha1
        {
        case nil, sha1?:
            let edition:PackageEdition = .init(id: edition,
                name: refname,
                sha1: sha1)

            //  This can fail if we race with another process.
            try await self.insert(edition, with: session)

        case _?:
            try await self.update(field: PackageEdition[.lost],
                of: edition,
                to: true,
                with: session)
        }

        return placement
    }
}
extension PackageDatabase.Editions
{
    private
    func place(
        package:Int32,
        refname:String,
        with session:Mongo.Session) async throws -> Placement
    {
        let pipeline:Mongo.Pipeline = .init
        {
            let new:Mongo.KeyPath = "new"
            let old:Mongo.KeyPath = "old"
            let all:Mongo.KeyPath = "all"

            $0.stage
            {
                $0[.match] = .init
                {
                    $0[PackageEdition[.package]] = package
                }
            }
            $0.stage
            {
                $0[.facet] = .init
                {
                    $0[old] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[PackageEdition[.name]] = refname
                            }
                        }

                        $0.stage
                        {
                            $0[.replaceWith] = .init
                            {
                                $0[Placement[.cell]] = PackageEdition[.version]
                                $0[Placement[.sha1]] = PackageEdition[.sha1]
                            }
                        }
                    }
                    $0[new] = .init
                    {
                        $0.stage
                        {
                            $0[.sort] = .init
                            {
                                $0[PackageEdition[.version]] = (-)
                            }
                        }
                        $0.stage
                        {
                            $0[.limit] = 1
                        }
                        $0.stage
                        {
                            $0[.replaceWith] = .init
                            {
                                $0[Placement[.cell]] = .expr
                                {
                                    $0[.add] = (PackageEdition[.version], 1)
                                }
                            }
                        }
                    }
                }
            }
            $0.stage
            {
                $0[.set] = .init
                {
                    $0[all] = .expr { $0[.concatArrays] = (old, new) }
                }
            }
            $0.stage
            {
                $0[.unwind] = all
            }
            $0.stage
            {
                $0[.replaceWith] = all
            }
            $0.stage
            {
                $0[.limit] = 1
            }
        }

        let placement:[Placement] = try await session.run(
            command: Mongo.Aggregate<Mongo.SingleBatch<Placement>>.init(Self.name,
                pipeline: pipeline),
            against: self.database)

        return placement.first ?? .first
    }
}
extension PackageDatabase.Editions
{
    public
    func missing(graphs:PackageDatabase.Graphs) async throws
    {
        //  TODO: this does a full collection scan. We should maintain some flags within
        //  the ``PackageEdition``s to cache whether or not they have graphs.
    }
}
