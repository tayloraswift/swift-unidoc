import BSON
import LZ77
import S3
import S3Client
import SymbolGraphs
import UnidocRecords

extension Swiftinit
{
    struct GraphLoader
    {
        private
        let s3:AWS.S3.Connection

        init(s3:AWS.S3.Connection)
        {
            self.s3 = s3
        }
    }
}
extension Swiftinit.GraphLoader:Unidoc.GraphLoader
{
    func load(graph:Unidoc.GraphPath) async throws -> ArraySlice<UInt8>
    {
        var bytes:[UInt8] = try await self.s3.get(path: "\(graph)")

        switch graph.type
        {
        case .bson:
            break

        case .bson_zz:
            var inflator:LZ77.Inflator = .init(format: .zlib)
            try inflator.push((consume bytes)[...])
            bytes = inflator.pull()
        }

        return bytes[...]
    }
}
