import HTTP
import MongoDB
import URI

extension Unidoc
{
    struct UserRenderOperation:Sendable
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
extension Unidoc.UserRenderOperation
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
                authorization: .api(account, .init(bitPattern: apiKey)),
                request: request)
        }
        else
        {
            self.init(authorization: authorization, request: request)
        }
    }
}
extension Unidoc.UserRenderOperation:Unidoc.PublicOperation
{
    func load(from server:borrowing Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        let session:Mongo.Session
        let remaining:Int?

        switch self.authorization
        {
        case .invalid(let error):
            return .unauthorized("\(error)\n")

        case .web:
            return .unauthorized("Missing authorization header\n")

        case .api(let account, let apiKey):
            session = try await .init(from: server.db.sessions)
            remaining = try await server.db.users.charge(apiKey: apiKey,
                user: account,
                with: session)
        }

        guard
        let remaining:Int
        else
        {
            return .resource("Inactive or nonexistent API key\n", status: 429)
        }

        var endpoint:Unidoc.ExportEndpoint = .init(rateLimit: .init(remaining: remaining),
            query: self.request)

        try await endpoint.pull(from: server.db.unidoc.id, with: session)

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
