import Codelinks

public
struct StaticResolver
{
    private
    var paths:Overload<Int32>.Table<CaseInsensitiveCollation>
    private
    var table:Overload<Int32>.Table<CaseSensitiveCollation>

    public
    init()
    {
        self.paths = .init()
        self.table = .init()
    }
}
extension StaticResolver
{
    public mutating
    func overload(_ path:QualifiedPath, with overload:__owned Overload<Int32>)
    {
        self.paths[path].append(overload)
        self.table[path].append(overload)
    }
}
extension StaticResolver:CodelinkResolver
{
    public
    subscript(path:[String]) -> Overload<Int32>.Accumulator
    {
        self.table[path]
    }
}
