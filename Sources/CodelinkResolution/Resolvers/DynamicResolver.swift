import Codelinks
import SymbolGraphs

public
struct DynamicResolver
{
    private
    var table:Overload<GlobalAddress>.Table<Codelink.Exact>

    public
    init()
    {
        self.table = .init()
    }
}
extension DynamicResolver
{
    public mutating
    func overload(_ path:QualifiedPath, with overload:__owned Overload<GlobalAddress>)
    {
        self.table[path].append(overload)
    }
}
extension DynamicResolver:CodelinkResolver
{
    public
    subscript(path:[String],
        collation _:Codelink.Path.Collation?) -> Overload<GlobalAddress>.Accumulator
    {
        self.table[path]
    }
}
