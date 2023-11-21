import GitHubClient
import GitHubAPI
import HTTP
import ModuleGraphs
import MongoDB
import SemanticVersions
import UnidocDB
import UnidocRecords

extension Server.Endpoint
{
    struct IndexRepoTag:Sendable
    {
        let package:PackageIdentifier
        let tag:String

        init(package:PackageIdentifier, tag:String)
        {
            self.package = package
            self.tag = tag
        }
    }
}
extension Server.Endpoint.IndexRepoTag:RestrictedEndpoint
{
    func load(from server:Server) async throws -> HTTP.ServerResponse?
    {
        guard
        let github:Server.PluginIntegration<GitHubPlugin> = server.github
        else
        {
            return nil
        }

        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        let package:Realm.Package = try await server.db.unidoc.packages.find(id: self.package,
            with: session)
        else
        {
            return .notFound("No such package")
        }

        guard
        case .github(let repo) = package.repo
        else
        {
            return .notFound("Not a GitHub repository")
        }

        let response:GitHubPlugin.TagResponse = try await github.api.connect
        {
            try await $0.inspect(tag: self.tag,
                owner: repo.owner.login,
                repo: repo.name,
                pat: github.plugin.pat)
        }

        guard
        let tag:GitHub.Tag = response.tag
        else
        {
            return .notFound("No such tag")
        }

        guard
        let version:SemanticVersion = .init(refname: tag.name) ?? .init(swiftRelease: tag.name)
        else
        {
            return .ok("Ignored tag '\(tag.name)': not a semantic or swift version")
        }
        if  let coordinate:Int32 = try await server.db.unidoc.editions.register(tag,
                package: package.coordinate,
                version: version,
                with: session)
        {
            return .ok("Created tag '\(tag.name)' as '\(version)' (version = \(coordinate))")
        }
        else
        {
            return .ok("Updated tag '\(tag.name)' as '\(version)'")
        }
    }
}
