import HTTP
import MongoDB
import URI

extension Unidoc
{
    struct ExportOperation:Sendable
    {
        private
        let authorization:Authorization

        private
        let request:VertexQuery<LookupAdjacent>

        private
        init(authorization:Authorization, request:VertexQuery<LookupAdjacent>)
        {
            self.authorization = authorization
            self.request = request
        }
    }
}
extension Unidoc.ExportOperation
{
    init(authorization:Unidoc.Authorization,
        request:Unidoc.VertexQuery<Unidoc.LookupAdjacent>,
        _query:__shared URI.Query)
    {
        //  Backwards compatibility with the previous API
        var account:Unidoc.Account?
        var apiKey:UInt64?
        for (key, value):(String, String) in _query.parameters
        {
            switch key
            {
            case "account": account = .init(value)
            case "api_key": apiKey = .init(value, radix: 16)
            case _:         continue
            }
        }

        if  let account:Unidoc.Account,
            let apiKey:UInt64,
            case .web = authorization
        {
            self.init(
                authorization: .api(.init(id: account, apiKey: .init(bitPattern: apiKey))),
                request: request)
        }
        else
        {
            self.init(authorization: authorization, request: request)
        }
    }
}
extension Unidoc.ExportOperation:Unidoc.PublicOperation
{
    func load(from server:Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
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
                user: authorization.id)
        }

        guard
        let remaining:Int
        else
        {
            return .resource("Inactive or nonexistent API key\n", status: 429)
        }

        var endpoint:Unidoc.ExportEndpoint = .init(rateLimit: .init(remaining: remaining),
            query: self.request)

        try await endpoint.pull(from: db.id, with: db.session)

        do
        {
            return try endpoint.response(as: format)
        }
        catch let error
        {
            return .resource("Error: \(error)\n", status: 400)
        }
    }
}
