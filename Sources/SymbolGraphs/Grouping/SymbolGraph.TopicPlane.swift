extension SymbolGraph
{
    @frozen public
    enum TopicPlane:SymbolGraph.PlaneType
    {
        @inlinable public static
        var plane:SymbolGraph.Plane { .topic }
    }
}
