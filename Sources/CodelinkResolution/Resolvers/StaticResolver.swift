import Codelinks
import SymbolGraphs

public
struct StaticResolver
{
    private
    var legacy:Overload<ScalarAddress>.Table<Codelink.LegacyDocC>
    private
    var exact:Overload<ScalarAddress>.Table<Codelink.Exact>

    public
    init()
    {
        self.legacy = .init()
        self.exact = .init()
    }
}
extension StaticResolver
{
    public mutating
    func overload(_ path:QualifiedPath, with overload:__owned Overload<ScalarAddress>)
    {
        self.legacy[path].append(overload)
        self.exact[path].append(overload)
    }
}
extension StaticResolver:CodelinkResolver
{
    public
    subscript(path:[String],
        collation collation:Codelink.Path.Collation?) -> Overload<ScalarAddress>.Accumulator
    {
        switch collation
        {
        case nil:       return self.exact[path]
        case .legacy?:  return self.legacy[path]
        }
    }
}
