extension SymbolGraph.Plane
{
    @frozen public
    enum Autogroup:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .autogroup }
    }
}
