import BSONDecoding
import BSONEncoding

extension SymbolGraph
{
    @frozen public
    struct Node
    {
        @usableFromInline internal
        var local:Scalar?
        @usableFromInline internal
        var extensions:[Extension]

        @inlinable public
        init(_ local:Scalar? = nil, extensions:[Extension] = [])
        {
            self.local = local
            self.extensions = extensions
        }
    }
}
extension SymbolGraph.Node
{
    public mutating
    func push(_ extension:__owned SymbolGraph.Extension) -> Int
    {
        defer { self.extensions.append(`extension`) }
        return self.extensions.endIndex
    }
}
