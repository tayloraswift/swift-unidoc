import HTTP
import JSON
import MongoDB
import Symbols
import URI

extension Unidoc
{
    struct LoadEditionStateOperation:Sendable
    {
        private
        let authorization:Authorization
        private
        let package:Symbol.Package
        private
        let version:VersionPredicate

        init(authorization:Authorization, package:Symbol.Package, version:VersionPredicate)
        {
            self.authorization = authorization
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.LoadEditionStateOperation:Unidoc.PublicOperation
{
    func load(from server:Unidoc.Server,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session
        let remaining:Int?

        switch self.authorization
        {
        case .invalid(let error):
            return .unauthorized("\(error)\n")

        case .web:
            return .unauthorized("Missing authorization header\n")

        case .api(let authorization):
            session = try await .init(from: server.db.sessions)
            remaining = try await server.db.users.charge(apiKey: authorization.apiKey,
                user: authorization.id,
                cost: 1,
                with: session)
        }

        guard
        let _:Int = remaining
        else
        {
            return .resource("Inactive or nonexistent API key\n", status: 429)
        }

        guard
        let edition:Unidoc.EditionState = try await server.db.unidoc.editionState(
            package: self.package,
            version: self.version,
            with: session)
        else
        {
            return .resource("No such edition\n", status: 404)
        }

        let report:Unidoc.EditionStateReport = .init(id: edition.version.edition.id,
            volume: edition.version.volume?.symbol,
            build: edition.build.map
            {
                .init(request: $0.request, stage: $0.progress?.stage, failure: $0.failure)
            },
            graph: edition.version.graph.map
            {
                .init(action: $0.action, commit: $0.commit)
            })

        let json:JSON = .object(with: report.encode(to:))

        return .ok(.init(content: .init(
            body: .binary(json.utf8),
            type: .application(.json, charset: .utf8))))
    }
}
