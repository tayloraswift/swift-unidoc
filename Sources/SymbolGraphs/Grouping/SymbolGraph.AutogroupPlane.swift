extension SymbolGraph
{
    @frozen public
    enum AutogroupPlane:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .autogroup }
    }
}
