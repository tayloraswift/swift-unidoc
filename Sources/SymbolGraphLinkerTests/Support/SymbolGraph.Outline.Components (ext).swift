import SymbolGraphs

extension SymbolGraph.OutlineText:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String) { self.init(stringLiteral) }
}
