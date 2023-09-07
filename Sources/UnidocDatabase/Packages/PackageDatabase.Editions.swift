import BSON
import JSONEncoding
import ModuleGraphs
import MongoDB
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
            command: Mongo.Find<Mongo.Cursor<IdentityView>>.init(Self.name,
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
                for view:IdentityView in $1
                {
                    $0.append(view.id)
                }
            }
        }
    }
}
extension PackageDatabase
{
    public
    func editions(of package:PackageIdentifier,
        with session:Mongo.Session) async throws -> [PackageEdition]
    {
        try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<PackageEdition>>.init(Packages.name,
                pipeline: .init
                {
                    $0.stage
                    {
                        $0[.match] = .init
                        {
                            $0[PackageCell[.id]] = package
                        }
                    }

                    let editions:Mongo.KeyPath = "editions"

                    $0.stage
                    {
                        $0[.lookup] = .init
                        {
                            $0[.from] = Editions.name
                            $0[.localField] = PackageCell[.index]
                            $0[.foreignField] = PackageEdition[.package]
                            $0[.as] = editions
                        }
                    }

                    $0.stage
                    {
                        $0[.unwind] = editions
                    }

                    $0.stage
                    {
                        $0[.replaceWith] = editions
                    }
                },
                stride: 1),
            against: self.id)
        {
            try await $0.reduce(into: [], += )
        }
    }
}
extension PackageDatabase.Editions
{
    func zone(
        package:Int32,
        refname:String,
        with session:Mongo.Session) async throws -> Unidoc.Zone
    {
        let pipeline:Mongo.Pipeline = .init
        {
            let predecessor:Mongo.KeyPath = "predecessor"
            let existing:Mongo.KeyPath = "existing"
            let editions:Mongo.KeyPath = "editions"

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
                    $0[predecessor] = .init
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
                            $0[.set] = .init
                            {
                                $0[PackageEdition[.version]] = .expr
                                {
                                    $0[.add] = (PackageEdition[.version], 1)
                                }
                            }
                        }
                    }
                    $0[existing] = .init
                    {
                        $0.stage
                        {
                            $0[.match] = .init
                            {
                                $0[PackageEdition[.name]] = refname
                            }
                        }
                    }
                }
            }
            $0.stage
            {
                $0[.set] = .init
                {
                    $0[editions] = .expr { $0[.concatArrays] = (predecessor, existing) }
                }
            }
            $0.stage
            {
                $0[.unwind] = editions
            }
            $0.stage
            {
                $0[.set] = .init
                {
                    $0[PackageEdition[.version]] = editions / PackageEdition[.version]
                }
            }
            $0.stage
            {
                //  If a snapshot with the same revision already exists, return that first.
                $0[.sort] = .init
                {
                    $0[PackageEdition[.version]] = (+)
                }
            }
            $0.stage
            {
                $0[.project] = .init
                {
                    //  The `_id` will not always be present, but the version will be.
                    //  Some of the documents are missing the `_id` field because they
                    //  are generated.
                    $0[PackageEdition[.version]] = true
                    $0[PackageEdition[.id]] = false
                }
            }
            $0.stage
            {
                $0[.limit] = 1
            }
        }

        let version:Int32 = try await session.run(
            command: Mongo.Aggregate<Mongo.Cursor<VersionView>>.init(Self.name,
                pipeline: pipeline,
                stride: 1),
            against: self.database)
        {
            try await $0.reduce(into: [], +=).first?.version ?? 0
        }

        return .init(package: package, version: version)
    }
}
