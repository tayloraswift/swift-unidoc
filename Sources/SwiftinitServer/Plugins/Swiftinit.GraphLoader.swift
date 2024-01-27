import BSON
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
    func load(graph:Unidoc.GraphPath) async throws -> [UInt8]
    {
        try await self.s3.get(path: "\(graph)")
    }
}
