import HTTP
import MongoDB
import UnidocDB

protocol ProceduralEndpoint:Sendable
{
    func perform(on server:borrowing Swiftinit.Server,
        with payload:[UInt8]) async throws -> HTTP.ServerResponse
}
