extension SymbolGraph
{
    public
    typealias PlaneType = _SymbolGraphPlaneType
}

/// The name of this protocol is ``SymbolGraph.Plane``.
public
protocol _SymbolGraphPlaneType
{
    static
    var plane:SymbolGraph.Plane { get }
}
