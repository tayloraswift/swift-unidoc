extension SymbolGraph
{
    @frozen public
    enum ExtensionPlane:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .extension }
    }
}
