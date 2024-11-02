import UnidocRecords

extension Unidoc
{
    enum NoLoader:GraphLoader
    {
        func load(graph:GraphPath) async throws -> ArraySlice<UInt8>
        {
            fatalError("unreachable")
        }
    }
}
