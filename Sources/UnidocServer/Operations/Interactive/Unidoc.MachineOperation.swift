import HTTP
import JSON
import MongoDB
import UnidocDB

extension Unidoc
{
    public
    protocol MachineOperation:RestrictedOperation
    {
        func load(from server:borrowing Server,
            with session:Mongo.Session) async throws -> JSON?
    }
}
extension Unidoc.MachineOperation
{
    /// The machine endpoints are restricted to administratrices and machine users.
    @inlinable public
    func admit(level:Unidoc.User.Level) -> Bool
    {
        switch level
        {
        case .administratrix:   true
        case .machine:          true
        case .human:            false
        }
    }

    public
    func load(from server:borrowing Unidoc.Server,
        with session:Mongo.Session) async throws -> HTTP.ServerResponse?
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
