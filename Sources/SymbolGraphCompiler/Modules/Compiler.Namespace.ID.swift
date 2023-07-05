import ModuleGraphs

extension Compiler.Namespace
{
    @frozen public
    enum ID:Equatable, Hashable, Comparable, Sendable
    {
        case index(Int)
        case nominated(ModuleIdentifier)
    }
}
extension Compiler.Namespace.ID
{
    var index:Int?
    {
        switch self
        {
        case .index(let index): return index
        case .nominated:        return nil
        }
    }
}
