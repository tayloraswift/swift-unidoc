import BSON
import JSON
import MongoDB
import SymbolGraphs
import Symbols
import UnidocRecords
import UnixTime

extension Unidoc.DB
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
extension Unidoc.DB.Packages
{
    public static
    let indexAccount:Mongo.CollectionIndex = .init("RepoAccount", unique: false)
    {
        $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.account]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.account]]
        {
            $0[.exists] = true
        }
    }

    public static
    let indexRepoCreated:Mongo.CollectionIndex = .init("RepoCreated", unique: false)
    {
        $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.created]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.repo]] { $0[.exists] = true }
    }

    public static
    let indexRepoGitHub:Mongo.CollectionIndex = .init("RepoGitHub", unique: true)
    {
        $0[ Unidoc.PackageMetadata[.repo] /
            Unidoc.PackageRepo[.github] /
            Unidoc.GitHubOrigin[.id]] = (+)
    }
        where:
    {
        $0[ Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.github]]
        {
            $0[.exists] = true
        }
    }

    public static
    let indexRealm:Mongo.CollectionIndex = .init("Realm", unique: false)
    {
        $0[Unidoc.PackageMetadata[.realm]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.realm]] { $0[.exists] = true }
    }
}
extension Unidoc.DB.Packages:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.PackageMetadata

    @inlinable public static
    var name:Mongo.Collection { "Packages" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex]
    {
        [
            Self.indexAccount,
            Self.indexRepoCreated,
            Self.indexRepoGitHub,
            Self.indexRealm,
        ]
    }
}
extension Unidoc.DB.Packages:Mongo.RecodableModel
{
    public
    func recode(with session:Mongo.Session) async throws -> (modified:Int, of:Int)
    {
        try await self.recode(through: Unidoc.PackageMetadata.self,
            with: session,
            by: .now.advanced(by: .seconds(30)))
    }
}
extension Unidoc.DB.Packages
{
    public
    func reset(media:Unidoc.PackageMedia?,
        of package:Unidoc.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.reset(field: .media,
            of: package,
            to: media,
            with: session)
    }

    public
    func reset(platformPreference triple:Triple?,
        of package:Unidoc.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.reset(field: .platformPreference,
            of: package,
            to: triple,
            with: session)
    }
}
extension Unidoc.DB.Packages
{
    public
    func insert(editor:Unidoc.Account,
        into package:Unidoc.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(existing: package, with: session)
        {
            $0[.addToSet]
            {
                $0[Unidoc.PackageMetadata[.editors]] = editor
            }
        }
    }
    public
    func revoke(editor:Unidoc.Account,
        from package:Unidoc.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(existing: package, with: session)
        {
            $0[.pull]
            {
                $0[Unidoc.PackageMetadata[.editors]] = editor
            }
        }
    }
}
extension Unidoc.DB.Packages
{
    public
    func findGitHub(repo id:Int32,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        let command:Mongo.Find<Mongo.Single<Unidoc.PackageMetadata>> = .init(Self.name,
            limit: 1)
        {
            $0[.filter]
            {
                //  We need this to use the partial index, for some reason.
                $0[ Unidoc.PackageMetadata[.repo] /
                    Unidoc.PackageRepo[.github]] { $0[.exists] = true }

                $0[ Unidoc.PackageMetadata[.repo] /
                    Unidoc.PackageRepo[.github] /
                    Unidoc.GitHubOrigin[.id]] = id
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
        symbol:Symbol.Package,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(field: .symbol, of: package, to: symbol, with: session)
    }

    public
    func update(package:Unidoc.Package,
        repo:Unidoc.PackageRepo?,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(existing: package, with: session)
        {
            if  let repo:Unidoc.PackageRepo
            {
                $0[.set] { $0[Element[.repo]] = repo }
            }
            else
            {
                $0[.unset] { $0[Element[.repo]] = () }
            }
        }
    }

    public
    func update(package:Unidoc.Package,
        hidden:Bool,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(existing: package, with: session)
        {
            if  hidden
            {
                $0[.set]
                {
                    $0[Unidoc.PackageMetadata[.hidden]] = true
                }
            }
            else
            {
                $0[.unset]
                {
                    $0[Unidoc.PackageMetadata[.hidden]] = ()
                }
            }
        }
    }
}
extension Unidoc.DB.Packages
{
    func scan(
        with session:Mongo.Session) async throws -> Unidoc.TextResource<Unidoc.DB.Metadata.Key>
    {
        //  TODO: this should project the `_id`
        let json:JSON = try await .array
        {
            (json:inout JSON.ArrayEncoder) in

            try await session.run(
                command: Mongo.Find<Mongo.Cursor<Unidoc.PackageMetadata>>.init(Self.name,
                    stride: 1024)
                {
                    $0[.filter]
                    {
                        $0[Unidoc.PackageMetadata[.hidden]] { $0[.exists] = false }
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

        return .init(id: .packages_json, text: .utf8(json.utf8[...]))
    }
}
