extension SymbolGraph.Scalars
{
    @frozen public
    struct Node
    {
        @usableFromInline internal
        var local:SymbolGraph.Scalar?
        @usableFromInline internal
        var extensions:[SymbolGraph.Extension]

        @inlinable public
        init(_ local:SymbolGraph.Scalar? = nil, extensions:[SymbolGraph.Extension] = [])
        {
            self.local = local
            self.extensions = extensions
        }
    }
}
extension SymbolGraph.Scalars.Node
{
    public mutating
    func push(_ extension:__owned SymbolGraph.Extension) -> Int
    {
        defer { self.extensions.append(`extension`) }
        return self.extensions.endIndex
    }
}
