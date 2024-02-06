import BSON
import HTTP
import JSON
import MongoDB
import SymbolGraphs
import UnidocDB

extension Swiftinit
{
    /// This endpoint is used to index and store a symbol graph in the database. It is virtually
    /// identical to `Swiftinit.GraphStorageEndpoint` except it is capable of registering
    /// documentation that has not yet been indexed by the GitHub plugin.
    enum GraphPlacementEndpoint:Sendable
    {
        case put
    }
}
extension Swiftinit.GraphPlacementEndpoint:BlockingEndpoint
{
    func perform(on server:borrowing Swiftinit.Server,
        payload:consuming [UInt8],
        session:Mongo.Session) async throws -> HTTP.ServerResponse
    {
        switch self
        {
        case .put:
            let docs:SymbolGraphObject<Void> = try .init(
                bson: BSON.Document.init(bytes: payload[...]))

            let uploaded:Unidoc.UploadStatus = try await server.db.unidoc.store(
                docs: consume docs,
                with: session)

            let json:JSON = .encode(uploaded)

            return .ok(.init(content: .binary(json.utf8),
                type: .application(.json, charset: .utf8)))
        }
    }
}
