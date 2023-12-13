import BSON
import HTTP
import JSON
import MongoDB
import SymbolGraphs
import UnidocAutomation
import UnidocDB

extension Swiftinit
{
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
            let docs:SymbolGraphArchive = try .init(
                bson: BSON.DocumentView<[UInt8]>.init(slice: payload))

            let uploaded:UnidocDatabase.Uploaded = try await server.db.unidoc.store(
                docs: consume docs,
                with: session)

            let json:JSON = .encode(UnidocAPI.Placement.init(edition: uploaded.edition))

            return .ok(.init(content: .binary(json.utf8),
                type: .application(.json, charset: .utf8)))
        }
    }
}
