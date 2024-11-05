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
        $0[Element[.repo] / Unidoc.PackageRepo[.github] / Unidoc.GitHubOrigin[.id]] = (+)
    }
        where:
    {
        $0[Element[.repo] / Unidoc.PackageRepo[.github]] { $0[.exists] = true }
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
}
extension Unidoc.DB.Packages
{
    public
    func set(media:Unidoc.PackageMedia,
        of package:Unidoc.Package) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(id: package)
        {
            if  media == .init()
            {
                $0[.unset] { $0[Element[.media]] = true }
            }
            else
            {
                $0[.set] { $0[Element[.media]] = media }
            }
        }
    }

    public
    func set(build:Unidoc.BuildTemplate,
        of package:Unidoc.Package) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(id: package)
        {
            $0[.set]
            {
                $0[Element[.build_toolchain]] = build.toolchain
                $0[Element[.build_platform]] = build.platform
            }
            $0[.unset]
            {
                $0[Element[.build_toolchain]] = build.toolchain == nil
                $0[Element[.build_platform]] = build.platform == nil
            }
        }
    }
}
extension Unidoc.DB.Packages
{
    public
    func insert(editor:Unidoc.Account,
        into package:Unidoc.Package) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(id: package)
        {
            $0[.addToSet]
            {
                $0[Unidoc.PackageMetadata[.editors]] = editor
            }
        }
    }
    public
    func revoke(editor:Unidoc.Account,
        from package:Unidoc.Package) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(id: package)
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
    func update(package:Unidoc.Package,
        repo:Unidoc.PackageRepo?) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(id: package)
        {
            if  let repo:Unidoc.PackageRepo
            {
                $0[.set] { $0[Element[.repo]] = repo }
            }
            else
            {
                $0[.unset] { $0[Element[.repo]] = true }
            }
        }
    }

    public
    func update(package:Unidoc.Package,
        hidden:Bool) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(id: package)
        {
            if  hidden
            {
                $0[.set] { $0[Unidoc.PackageMetadata[.hidden]] = true }
            }
            else
            {
                $0[.unset] { $0[Unidoc.PackageMetadata[.hidden]] = true }
            }
        }
    }

    public
    func updateWebhook(configurationURL:String,
        repo:Unidoc.PackageRepo) async throws -> Unidoc.PackageMetadata?
    {
        switch repo.origin
        {
        case .github(let origin):
            try await self.modifyByRegistrar(github: origin.id)
            {
                $0[.set]
                {
                    $0[Element[.repo]] = repo
                    $0[Element[.repoWebhook]] = configurationURL
                }
            }
        }
    }

    public
    func detachWebhook(package:Unidoc.Package) async throws -> Unidoc.PackageMetadata?
    {
        try await self.modify(id: package)
        {
            $0[.unset]
            {
                $0[Unidoc.PackageMetadata[.repoWebhook]] = true
            }
        }
    }
}
extension Unidoc.DB.Packages
{
    func modifyByRegistrar(github id:Int32,
        returning phase:Mongo.UpdatePhase = .new,
        update:(inout Mongo.UpdateEncoder) -> ()) async throws -> Element?
    {
        try await self.modify(by: Self.indexRepoGitHub)
        {
            $0[Element[.repo] / Unidoc.PackageRepo[.github] / Unidoc.GitHubOrigin[.id]] = id
            $0[Element[.repo] / Unidoc.PackageRepo[.github]]
            {
                $0[.exists] = true
            }
        }
            update:
        {
            update(&$0)
        }
    }
}
extension Unidoc.DB.Packages
{
    func scan() async throws -> Unidoc.TextResource<Unidoc.DB.Metadata.Key>
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
