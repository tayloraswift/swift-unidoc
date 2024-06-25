import HTTP
import JSON
import MongoDB
import UnidocDB
import UnidocRender

extension Unidoc
{
    public
    protocol MachineOperation:RestrictedOperation
    {
        func load(from server:Server, with session:Mongo.Session) async throws -> JSON?
    }
}
extension Unidoc.MachineOperation
{
    /// The machine endpoints are restricted to administratrices and machine users.
    @inlinable public
    func admit(user:Unidoc.UserRights) -> Bool
    {
        switch user.level
        {
        case .administratrix:   true
        case .machine:          true
        case .human:            false
        case .guest:            false
        }
    }

    public
    func load(from server:Unidoc.Server,
        with session:Mongo.Session,
        as _:Unidoc.RenderFormat) async throws -> HTTP.ServerResponse?
    {
        guard
        let json:JSON = try await self.load(from: server, with: session)
        else
        {
            return .notFound("")
        }

        return .ok(.init(content: .init(
            body: .binary(json.utf8),
            type: .application(.json, charset: .utf8))))
    }
}
