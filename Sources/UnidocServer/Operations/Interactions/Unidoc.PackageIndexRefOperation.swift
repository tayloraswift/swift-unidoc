import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import SemanticVersions
import SHA1
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct PackageIndexRefOperation:Sendable
    {
        let account:Account
        let package:Package
        let ref:String

        var privileges:User.Level

        init(account:Account, package:Package, ref:String)
        {
            self.account = account
            self.package = package
            self.ref = ref

            self.privileges = .human
        }
    }
}
extension Unidoc.PackageIndexRefOperation:Unidoc.MeteredOperation
{
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
    {
        let github:GitHub.Client<GitHub.API<String>>
        if  let api:GitHub.API<String> = server.github?.api
        {
            github = .graphql(api: api,
                threads: server.context.threads,
                niossl: server.context.niossl)
        }
        else
        {
            return nil
        }

        guard
        let package:Unidoc.PackageMetadata = try await server.db.packages.find(id: self.package,
            with: session)
        else
        {
            return .notFound("No such package")
        }

        guard
        case .github(let origin) = package.repo?.origin
        else
        {
            return .notFound("Not a GitHub repository")
        }

        if  let error:HTTP.ServerResponse = try await self.charge(cost: 8,
                from: server,
                with: session)
        {
            return error
        }

        let response:GitHub.RefResponse = try await github.connect
        {
            try await $0.inspect(ref: self.ref, owner: origin.owner, repo: origin.name)
        }

        guard
        let tag:GitHub.Ref = response.ref
        else
        {
            return .notFound("No such ref")
        }

        let version:SemanticVersion? = package.symbol.version(tag: tag.name)
        let sha1:SHA1?

        switch tag.prefix
        {

        case nil, .remotes?:
            return .ok("Ignored remote '\(tag.name)': not a tag or branch")

        case .tags?:
            guard case _? = version
            else
            {
                return .ok("Ignored tag '\(tag.name)': not a semantic or swift version")
            }

            sha1 = tag.hash

        case .heads?:
            sha1 = nil
        }

        let (_, _):(Unidoc.EditionMetadata, Bool) = try await server.db.unidoc.index(
            package: package.id,
            version: version,
            name: tag.name,
            sha1: sha1,
            with: session)

        return .redirect(.seeOther("\(Unidoc.TagsEndpoint[package.symbol])"))
    }
}
