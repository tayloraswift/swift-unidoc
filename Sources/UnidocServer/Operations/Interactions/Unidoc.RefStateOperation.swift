import HTTP
import JSON
import MongoDB
import Symbols
import URI

extension Unidoc
{
    struct RefStateOperation:Sendable
    {
        private
        let authorization:Authorization
        private
        let symbol:Symbol.PackageAtRef

        init(authorization:Authorization, symbol:Symbol.PackageAtRef)
        {
            self.authorization = authorization
            self.symbol = symbol
        }
    }
}
extension Unidoc.RefStateOperation:Unidoc.PublicOperation
{
    func load(from server:Unidoc.Server,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let remaining:Int?
        let db:Unidoc.DB

        switch self.authorization
        {
        case .invalid(let error):
            return .unauthorized("\(error)\n")

        case .web:
            return .unauthorized("Missing authorization header\n")

        case .api(let authorization):
            db = try await server.db.session()
            remaining = try await db.users.charge(
                apiKey: authorization.apiKey,
                user: authorization.id,
                cost: 1)
        }

        guard
        let _:Int = remaining
        else
        {
            return .resource("Inactive or nonexistent API key\n", status: 429)
        }

        guard
        let ref:Unidoc.RefState = try await db.ref(by: self.symbol)
        else
        {
            return .resource("No such edition\n", status: 404)
        }

        let report:Unidoc.EditionStateReport = .init(id: ref.version.edition.id,
            volume: ref.version.volume?.symbol,
            build: ref.build.map
            {
                .init(request: $0.request, stage: $0.progress?.stage, failure: $0.failure)
            },
            graph: ref.version.graph.map
            {
                .init(action: $0.action, commit: $0.commit)
            })

        let json:JSON = .object(with: report.encode(to:))

        return .ok(.init(content: .init(
            body: .binary(json.utf8),
            type: .application(.json, charset: .utf8))))
    }
}
