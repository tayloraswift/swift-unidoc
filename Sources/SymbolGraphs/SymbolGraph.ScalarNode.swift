extension SymbolGraph
{
    @frozen public
    struct ScalarNode
    {
        public
        var local:Scalar?
        public
        var extensions:[Extension]

        @inlinable public
        init(_ local:Scalar? = nil, extensions:[Extension] = [])
        {
            self.local = local
            self.extensions = extensions
        }
    }
}
