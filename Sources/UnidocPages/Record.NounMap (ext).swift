import HTTPServer
import UnidocAnalysis
import UnidocRecords
import URI

extension Record.NounMap:ServerResponseFactory
{
    public
    func response(for _:URI) throws -> ServerResponse
    {
        .resource(.init(.one(canonical: nil),
            content: .binary(self.json.utf8),
            type: .application(.json, charset: .utf8)))
    }
}
