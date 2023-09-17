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
            $0[.collation] = PackageDatabase.collation

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
        .init
        {
            $0[.unique] = true
            $0[.name] = "package,patch,version (release:false)"
            $0[.key] = .init
            {
                $0[PackageEdition[.package]] = (-)
                $0[PackageEdition[.patch]] = (-)
                $0[PackageEdition[.version]] = (-)
            }

            $0[.partialFilterExpression] = .init
            {
                $0[PackageEdition[.release]] = .init { $0[.eq] = false }
                $0[PackageEdition[.release]] = .init { $0[.exists] = true }
                $0[PackageEdition[.patch]] = .init { $0[.exists] = true }
            }
        },
        .init
        {
            $0[.unique] = true
            $0[.name] = "package,patch,version (release:true)"
            $0[.key] = .init
            {
                $0[PackageEdition[.package]] = (-)
                $0[PackageEdition[.patch]] = (-)
                $0[PackageEdition[.version]] = (-)
            }

            $0[.partialFilterExpression] = .init
            {
                $0[PackageEdition[.release]] = .init { $0[.eq] = true }
                $0[PackageEdition[.release]] = .init { $0[.exists] = true }
                $0[PackageEdition[.patch]] = .init { $0[.exists] = true }
            }
        },
    ]
}
extension PackageDatabase.Editions
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: PackageEdition.self,
            with: session,
            by: .now.advanced(by: .seconds(60)))
    }
}
extension PackageDatabase.Editions
{
    public
    func register(_ tag:__owned GitHubAPI.Tag,
        package:Int32,
        with session:Mongo.Session) async throws -> Int32?
    {
        //  We use the SHA-1 hash as “proof” that the edition has at least one symbol graph.
        //  Therefore, merely registering tags does not update hashes.
        let placement:Placement = try await self.register(package: package,
            refname: tag.name,
            sha1: nil,
            with: session)

        return placement.new ? placement.coordinate : nil
    }

    func register(
        package:Int32,
        refname:String,
        sha1:SHA1?,
        with session:Mongo.Session) async throws -> Placement
    {
        //  Placement involves autoincrement, which is why this cannot be done in an update.
        let placement:Placement = try await self.place(
            package: package,
            refname: refname,
            with: session)

        let edition:PackageEdition = .init(id: .init(
                package: package,
                version: placement.coordinate),
            name: refname,
            sha1: sha1)

        if  placement.new
        {
            //  This can fail if we race with another process.
            try await self.insert(edition, with: session)
        }
        else if let sha1:SHA1
        {
            switch placement.sha1
            {
            case nil:
                //  If the edition would gain a hash, we should update it.

                //  FIXME: this can race another update, in which case we will store an
                //  arbitrary choice of hash without marking the edition dirty.
                //  We should use `placement.sha1` as a hint to skip the update only,
                //  and set the dirty flag within a custom update statement.
                try await self.update(edition, with: session)

            case sha1?:
                //  Nothing to do.
                break

            case _?:
                try await self.update(field: PackageEdition[.lost],
                    of: edition.id,
                    to: true,
                    with: session)
            }
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
                                $0[Placement[.coordinate]] = PackageEdition[.version]
                                $0[Placement[.sha1]] = PackageEdition[.sha1]
                                $0[Placement[.new]] = false
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
                                $0[Placement[.coordinate]] = .expr
                                {
                                    $0[.add] = (PackageEdition[.version], 1)
                                }
                                $0[Placement[.new]] = true
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
