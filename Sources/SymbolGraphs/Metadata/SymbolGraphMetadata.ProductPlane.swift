extension SymbolGraphMetadata
{
    @frozen public
    enum ProductPlane:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .product }
    }
}
