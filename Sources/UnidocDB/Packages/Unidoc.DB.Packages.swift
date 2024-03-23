import BSON
import JSON
import MongoDB
import Symbols
import UnidocRecords

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
    let indexBuildQueue:Mongo.CollectionIndex = .init("BuildQueue", unique: false)
    {
        $0[Unidoc.PackageMetadata[.buildRequest]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.buildRequest]] { $0[.exists] = true }
    }

    public static
    let indexBuildStarted:Mongo.CollectionIndex = .init("BuildStarted", unique: false)
    {
        $0[Unidoc.PackageMetadata[.buildProgress] / Unidoc.BuildProgress[.started]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.buildProgress]] { $0[.exists] = true }
    }

    public static
    let indexExpiration:Mongo.CollectionIndex = .init("RepoExpires", unique: false)
    {
        $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.expires]] = (+)
    }
        where:
    {
        $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.expires]]
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
            Self.indexBuildQueue,
            Self.indexBuildStarted,
            Self.indexExpiration,
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

    @discardableResult
    public
    func update(package:Unidoc.Package,
        symbol:Symbol.Package,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(field: .symbol, of: package, to: symbol, with: session)
    }

    @discardableResult
    public
    func update(package:Unidoc.Package,
        repo:Unidoc.PackageRepo?,
        with session:Mongo.Session) async throws -> Bool?
    {
        try await self.update(field: .repo, of: package, to: repo, with: session)
    }

    public
    func update(package:Unidoc.Package,
        expires time:BSON.Millisecond,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        let (package, _):(Unidoc.PackageMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.PackageMetadata>>.init(
                Self.name,
                returning: .new)
            {
                $0[.query]
                {
                    $0[Unidoc.PackageMetadata[.id]] = package
                    $0[Unidoc.PackageMetadata[.repo]] { $0[.exists] = true }
                }
                $0[.update]
                {
                    $0[.set]
                    {
                        $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.expires]] = time
                    }
                }
            },
            against: self.database)
        return package
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
                $0[.query]
                {
                    $0[Unidoc.PackageMetadata[.id]] = package
                }
                $0[.update]
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
            $0[.filter]
            {
                $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.expires]]
                {
                    $0[.exists] = true
                }
            }
            $0[.sort]
            {
                $0[Unidoc.PackageMetadata[.repo] / Unidoc.PackageRepo[.expires]] = (+)
            }
            $0[.hint] = Self.indexExpiration.id
        }

        return try await session.run(command: command, against: self.database)
    }
}
extension Unidoc.DB.Packages
{
    func assignBuild(of edition:Unidoc.Edition,
        to builder:Unidoc.Account,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        let (package, _):(Unidoc.PackageMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.PackageMetadata>>.init(Self.name,
                returning: .new)
            {
                $0[.hint] = Self.indexBuildQueue.id
                $0[.query]
                {
                    $0[Unidoc.PackageMetadata[.id]] = edition.package
                    $0[Unidoc.PackageMetadata[.buildRequest]] { $0[.exists] = true }

                    $0[Unidoc.PackageMetadata[.buildProgress]] { $0[.exists] = false }
                }
                $0[.update]
                {
                    $0[.unset]
                    {
                        $0[Unidoc.PackageMetadata[.buildRequest]] = ()
                    }
                    $0[.set]
                    {
                        $0[Unidoc.PackageMetadata[.buildProgress]] = Unidoc.BuildProgress.init(
                            started: .now(),
                            edition: edition,
                            builder: builder)
                    }
                }
            },
            against: self.database)

        return package
    }

    func finishBuild(of package:Unidoc.Package,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        let (package, _):(Unidoc.PackageMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.PackageMetadata>>.init(Self.name,
                returning: .old)
            {
                $0[.query]
                {
                    $0[Unidoc.PackageMetadata[.buildProgress]] { $0[.exists] = true }
                }
                $0[.update]
                {
                    $0[.unset]
                    {
                        $0[Unidoc.PackageMetadata[.buildProgress]] = ()
                    }
                }
            },
            against: self.database)

        return package
    }

    func lintBuild(startedBefore:BSON.Millisecond,
        with session:Mongo.Session) async throws -> Unidoc.PackageMetadata?
    {
        let (package, _):(Unidoc.PackageMetadata?, Never?) = try await session.run(
            command: Mongo.FindAndModify<Mongo.Existing<Unidoc.PackageMetadata>>.init(Self.name,
                returning: .old)
            {
                $0[.query]
                {
                    $0[Unidoc.PackageMetadata[.buildProgress]] { $0[.exists] = true }
                    $0[Unidoc.PackageMetadata[.buildProgress] / Unidoc.BuildProgress[.started]]
                    {
                        $0[.lt] = startedBefore
                    }
                }
                $0[.update]
                {
                    $0[.unset]
                    {
                        $0[Unidoc.PackageMetadata[.buildProgress]] = ()
                    }
                }
            },
            against: self.database)

        return package
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
