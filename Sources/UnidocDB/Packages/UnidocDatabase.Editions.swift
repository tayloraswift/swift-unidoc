import BSON
import GitHubAPI
import JSONEncoding
import MongoDB
import SemanticVersions
import SHA1
import UnidocAnalysis
import UnidocRecords

extension UnidocDatabase
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
extension UnidocDatabase.Editions:DatabaseCollection
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
            $0[.collation] = UnidocDatabase.collation

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
extension UnidocDatabase.Editions
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: PackageEdition.self,
            with: session,
            by: .now.advanced(by: .seconds(60)))
    }
}
extension UnidocDatabase.Editions
{
    public
    func register(_ tag:__owned GitHub.Tag,
        package:Int32,
        version:SemanticVersion,
        with session:Mongo.Session) async throws -> Int32?
    {
        let placement:Placement = try await self.register(package: package,
            version: version,
            refname: tag.name,
            sha1: tag.hash,
            with: session)

        return placement.new ? placement.coordinate : nil
    }

    func register(
        package:Int32,
        version:SemanticVersion,
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
            release: version.release,
            patch: version.patch,
            name: refname,
            sha1: sha1)

        if  placement.new
        {
            //  This can fail if we race with another process.
            try await self.insert(some: edition, with: session)
        }
        else if let sha1:SHA1
        {
            switch placement.sha1
            {
            case sha1?:
                //  Nothing to do.
                break

            case _:
                try await self.update(some: edition, with: session)
            }
        }

        return placement
    }
}
extension UnidocDatabase.Editions
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
extension UnidocDatabase.Editions
{
    /// Removes all editions that lack a commit hash, unless it has the exact name
    /// `swift-5.8.1-RELEASE` or `swift-5.9-RELEASE`.
    public
    func _lint(with session:Mongo.Session) async throws -> Int
    {
        try await self.deleteAll(with: session)
        {
            $0[PackageEdition[.sha1]] = .init { $0[.exists] = false }
            $0[PackageEdition[.name]] = .init { $0[.ne] = "swift-5.8.1-RELEASE" }
            $0[PackageEdition[.name]] = .init { $0[.ne] = "swift-5.9-RELEASE" }
        }
    }
}
