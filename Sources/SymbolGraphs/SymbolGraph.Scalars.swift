extension SymbolGraph
{
    @frozen public
    struct Scalars
    {
        @usableFromInline internal
        var nodes:[ScalarNode]

        init(nodes:[ScalarNode] = [])
        {
            self.nodes = nodes
        }
    }
}
extension SymbolGraph
{
    @frozen public
    struct ScalarNode
    {
        var local:Scalar?
        var extensions:[Extension]
    }
}
extension SymbolGraph.Scalars
{
    subscript(local address:ScalarAddress) -> SymbolGraph.ScalarNode
    {
        _read
        {
            yield  self.nodes[.init(address.value)]
        }
        _modify
        {
            yield &self.nodes[.init(address.value)]
        }
    }
}
