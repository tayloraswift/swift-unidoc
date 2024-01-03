import BSON
import JSON
import MongoDB
import UnidocRecords

extension UnidocDatabase
{
    @frozen public
    struct Packages
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
extension UnidocDatabase.Packages
{
    public static
    let indexExpiration:Mongo.CollectionIndex = .init("LastCrawled", unique: false)
    {
        $0[Unidoc.PackageMetadata[.expires]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.repo]] = .init { $0[.exists] = true }
    }

    public static
    let indexRepoCreated:Mongo.CollectionIndex = .init("RepoCreated", unique: false)
    {
        $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.repo]] = .init { $0[.exists] = true }
    }

    public static
    let indexRepoGitHub:Mongo.CollectionIndex = .init("RepoGitHub", unique: true)
    {
        $0[ Unidoc.PackageMetadata[.repo] /
            Unidoc.PackageRepo[.github] /
            Unidoc.PackageRepo.GitHubOrigin[.id]] = (+)
    }
        where:
    {
        $0[ Unidoc.PackageMetadata[.repo] /
            Unidoc.PackageRepo[.github]] = .init { $0[.exists] = true }
    }

    public static
    let indexRealm:Mongo.CollectionIndex = .init("Realm", unique: false)
    {
        $0[Unidoc.PackageMetadata[.realm]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.realm]] = .init { $0[.exists] = true }
    }
}
extension UnidocDatabase.Packages:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.PackageMetadata

    @inlinable public static
    var name:Mongo.Collection { "Packages" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexExpiration,
            Self.indexRepoCreated,
            Self.indexRepoGitHub,
            Self.indexRealm,
        ]
    }
}
extension UnidocDatabase.Packages:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Unidoc.PackageMetadata.self,
            with: session,
            by: .now.advanced(by: .seconds(30)))
    }
}
extension UnidocDatabase.Packages
{
    func findGitHub(repo id:Int32,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        let command:Mongo.Find<Mongo.Single<Unidoc.PackageMetadata>> = .init(Self.name,
            limit: 1)
        {
            $0[.filter] = .init
            {
                //  We need this to use the partial index, for some reason.
                $0[ Unidoc.PackageMetadata[.repo] /
                    Unidoc.PackageRepo[.github]] = .init { $0[.exists] = true }

                $0[ Unidoc.PackageMetadata[.repo] /
                    Unidoc.PackageRepo[.github] /
                    Unidoc.PackageRepo.GitHubOrigin[.id]] = id
            }
            $0[.hint] = Self.indexRepoGitHub.id
        }

        return try await session.run(command: command, against: self.database)
    }

    public
    func update(metadata:Unidoc.PackageMetadata,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(some: metadata, with: session)
    }

    public
    func update(package:Unidoc.Package,
        hidden:Bool,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        let (package, _):(Unidoc.PackageMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.PackageMetadata>>.init(
                Self.name,
                returning: .new)
            {
                $0[.query] = .init
                {
                    $0[Unidoc.PackageMetadata[.id]] = package
                }
                $0[.update] = Mongo.UpdateDocument.init
                {
                    if  hidden
                    {
                        $0[.set] = .init
                        {
                            $0[Unidoc.PackageMetadata[.hidden]] = true
                        }
                    }
                    else
                    {
                        $0[.unset] = .init
                        {
                            $0[Unidoc.PackageMetadata[.hidden]] = ()
                        }
                    }
                }
            },
            against: self.database)
        return package
    }

    public
    func stalest(_ limit:Int,
        with session:Mongo.Session) async throws -> [Unidoc.PackageMetadata]
    {
        let command:Mongo.Find<Mongo.SingleBatch<Unidoc.PackageMetadata>> = .init(Self.name,
            limit: limit)
        {
            $0[.filter] = .init
            {
                $0[Unidoc.PackageMetadata[.repo]] = .init { $0[.exists] = true }
            }
            $0[.sort] = .init
            {
                $0[Unidoc.PackageMetadata[.expires]] = (+)
            }
            $0[.hint] = Self.indexExpiration.id
        }

        return try await session.run(command: command, against: self.database)
    }
}
extension UnidocDatabase.Packages
{
    func scan(with session:Mongo.Session) async throws -> SearchIndex<Int32>
    {
        //  TODO: this should project the `_id`
        let json:JSON = try await .array
        {
            (json:inout JSON.ArrayEncoder) in

            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Unidoc.PackageMetadata>>.init(Self.name,
                    stride: 1024)
                {
                    $0[.filter] = .init
                    {
                        $0[Unidoc.PackageMetadata[.hidden]] = .init { $0[.exists] = false }
                    }
                },
                against: self.database)
            {
                for try await batch:[Unidoc.PackageMetadata] in $0
                {
                    for cell:Unidoc.PackageMetadata in batch
                    {
                        json[+] = "\(cell.symbol)"
                    }
                }
            }
        }

        return .init(id: 0, json: json)
    }
}
