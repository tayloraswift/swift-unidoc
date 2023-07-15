import Sources

extension SymbolGraph.Outline
{
    @frozen public
    enum Referent:Equatable, Hashable, Sendable
    {
        case scalar(Int32)
        case vector(Int32, self:Int32)
        case unresolved(SourceLocation<Int32>?)
    }
}
