import SymbolGraphs

extension Unidoc
{
    public
    typealias GraphLoader = _UnidocGraphLoader
}
/// The name of this protocol is ``Unidoc.GraphLoader``.
public
protocol _UnidocGraphLoader
{
    func load(graph:Unidoc.GraphPath) async throws -> ArraySlice<UInt8>
}
