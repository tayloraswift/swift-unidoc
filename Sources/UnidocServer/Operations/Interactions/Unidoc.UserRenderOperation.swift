import HTTP
import MongoDB
import URI

extension Unidoc
{
    struct UserRenderOperation:Sendable
    {
        private
        let request:Unidoc.VertexQuery<Unidoc.LookupAdjacent>

        //  We do as little validation as possible here, because we want to return helpful error
        //  messages to the client.
        var account:String?
        var apiKey:String?


        private
        init(request:Unidoc.VertexQuery<Unidoc.LookupAdjacent>)
        {
            self.request = request
            self.account = nil
            self.apiKey = nil
        }
    }
}
extension Unidoc.UserRenderOperation
{
    init(volume:Unidoc.VolumeSelector,
        shoot:Unidoc.Shoot,
        query parameters:__shared [(key:String, value:String)]?)
    {
        self.init(request: .init(volume: volume, vertex: shoot))

        guard
        let parameters:[(key:String, value:String)]
        else
        {
            return
        }

        for (key, value):(String, String) in parameters
        {
            switch key
            {
            case "account": self.account = value
            case "api_key": self.apiKey = value
            case _:         continue
            }
        }
    }
}
extension Unidoc.UserRenderOperation:Unidoc.PublicOperation
{
    func load(from server:borrowing Unidoc.Server,
        as format:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        guard
        let account:String = self.account
        else
        {
            return .resource("Missing required parameter 'account'\n", status: 400)
        }
        guard
        let account:Unidoc.Account = .init(account)
        else
        {
            return .resource("Invalid format for parameter 'account'\n", status: 400)
        }
        guard
        let apiKey:String = self.apiKey
        else
        {
            return .resource("Missing required parameter 'api_key'\n", status: 400)
        }
        guard
        let apiKey:UInt64 = .init(apiKey, radix: 16)
        else
        {
            return .resource("Invalid format for parameter 'api_key'\n", status: 400)
        }

        let session:Mongo.Session = try await .init(from: server.db.sessions)

        guard
        let remaining:Int = try await server.db.users.charge(
            apiKey: .init(bitPattern: apiKey),
            user: account,
            with: session)
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
