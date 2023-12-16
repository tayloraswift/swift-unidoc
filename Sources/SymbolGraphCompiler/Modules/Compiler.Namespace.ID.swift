import Symbols

extension Compiler.Namespace
{
    @frozen public
    enum ID:Equatable, Hashable, Comparable, Sendable
    {
        case index(Int)
        case nominated(Symbol.Module)
    }
}
extension Compiler.Namespace.ID
{
    var index:Int?
    {
        switch self
        {
        case .index(let index): index
        case .nominated:        nil
        }
    }
}
