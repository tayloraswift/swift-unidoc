import HTTP
import JSON
import MongoDB

extension Swiftinit
{
    protocol MachineEndpoint:RestrictedEndpoint
    {
        func load(from server:borrowing Swiftinit.Server,
            with session:Mongo.Session) async throws -> JSON?
    }
}
extension Swiftinit.MachineEndpoint
{
    /// The machine endpoints are restricted to administratrices and machine users.
    func admit(level:Unidoc.User.Level) -> Bool
    {
        switch level
        {
        case .administratrix:   true
        case .machine:          true
        case .human:            false
        }
    }

    func load(from server:borrowing Swiftinit.Server,
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
