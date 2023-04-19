public
struct CodelinkResolver
{
    private
    var legacy:Table<LegacyDocC>
    private
    var exact:Table<Exact>

    public
    init()
    {
        self.legacy = .init()
        self.exact = .init()
    }
}
extension CodelinkResolver
{
    public mutating
    func overload(_ path:LexicalPath, with overload:__owned CodelinkResolver.Overload)
    {
        self.legacy[path].append(overload)
        self.exact[path].append(overload)
    }
}
