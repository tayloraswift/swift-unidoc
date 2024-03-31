import HTTP
import SwiftinitPages

extension Swiftinit
{
    protocol InteractiveEndpoint:Sendable
    {
        consuming
        func load(from server:borrowing Server,
            with credentials:Swiftinit.Credentials,
            as format:RenderFormat) async throws -> HTTP.ServerResponse?
    }
}
