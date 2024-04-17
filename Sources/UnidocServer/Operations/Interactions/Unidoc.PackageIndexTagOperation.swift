import GitHubAPI
import GitHubClient
import HTTP
import MongoDB
import SemanticVersions
import Symbols
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct PackageIndexTagOperation:Sendable
    {
        let package:Unidoc.Package
        let tag:String

        init(package:Unidoc.Package, tag:String)
        {
            self.package = package
            self.tag = tag
        }
    }
}
extension Unidoc.PackageIndexTagOperation:Unidoc.AdministrativeOperation
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

        let response:GitHub.TagResponse = try await github.connect
        {
            try await $0.inspect(tag: self.tag, owner: origin.owner, repo: origin.name)
        }

        guard
        let tag:GitHub.Tag = response.tag
        else
        {
            return .notFound("No such tag")
        }

        guard
        let version:SemanticVersion = package.symbol.version(tag: tag.name)
        else
        {
            return .ok("Ignored tag '\(tag.name)': not a semantic or swift version")
        }

        let (edition, new):(Unidoc.EditionMetadata, Bool) = try await server.db.unidoc.index(
            package: package.id,
            version: version,
            name: tag.name,
            sha1: tag.hash,
            with: session)

        return .ok("""
            \(new ? "Created" : "Updated") tag '\(edition.name)' as '\(version)' \
            (version = \(edition.id))
            """)
    }
}
