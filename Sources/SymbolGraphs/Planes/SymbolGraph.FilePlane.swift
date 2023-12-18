extension SymbolGraph
{
    @frozen public
    enum FilePlane:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .file }
    }
}
