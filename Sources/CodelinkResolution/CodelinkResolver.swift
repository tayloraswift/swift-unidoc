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
extension CodelinkResolver
{
    public
    func query(ascending scope:[String] = [], link:Codelink) -> Overloads?
    {
        for index:Int in (scope.startIndex ... scope.endIndex).reversed()
        {
            if  let overloads:Overloads = self.query(prepending: scope.prefix(upTo: index),
                    link: link)
            {
                return overloads
            }
        }
        return nil
    }
    private
    func query(prepending scope:ArraySlice<String>, link:Codelink) -> Overloads?
    {
        switch self[scope, link.scope, link.path]
        {
        case nil:
            return nil
        
        case .one(let overload):
            return .one(overload)
        
        case .many(let overloads):
            var filtered:Overloads? = nil

            if  let hash:Codelink.Hash = link.hash
            {
                for overload:Overload in overloads where hash == overload.hash
                {
                    filtered.append(overload)
                }
            }
            else if let filter:Codelink.Filter = link.filter
            {
                for overload:Overload in overloads where filter ~= overload.phylum
                {
                    filtered.append(overload)
                }
            }
            else
            {
                return .many(overloads)
            }

            return filtered
        }
    }
    private
    subscript(prefix:ArraySlice<String>,
        infix:Codelink.Scope?,
        path:Codelink.Path) -> Overloads?
    {
        switch path.collation
        {
        case nil:       return self.exact[path.components]
        case .legacy?:  return self.legacy[path.components]
        }
    }
}
