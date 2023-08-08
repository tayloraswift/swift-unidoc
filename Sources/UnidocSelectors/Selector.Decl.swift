import Symbols
import UnidocRecords

extension Selector
{
    @frozen public
    enum Decl:Equatable, Hashable, Sendable
    {
        case symbol(Symbol.Decl)
    }
}
