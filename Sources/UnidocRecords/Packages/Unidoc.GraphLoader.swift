import SymbolGraphs

extension Unidoc
{
    public
    protocol GraphLoader
    {
        func load(graph:GraphPath) async throws -> ArraySlice<UInt8>
    }
}
