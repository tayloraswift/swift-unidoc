import HTTP
import MongoDB
import UnidocDB

protocol ProceduralEndpoint:Sendable
{
    func perform(on server:Server, with payload:[UInt8]) async throws -> ServerResponse
}
