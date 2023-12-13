extension SymbolGraph.Plane
{
    @frozen public
    enum Topic:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .topic }
    }
}
