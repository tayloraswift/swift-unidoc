import Doclinks

@frozen public
struct DoclinkResolver
{
    public
    let table:Table
    public
    let scope:Scope?

    @inlinable public
    init(table:Table, scope:Scope?)
    {
        self.table = table
        self.scope = scope
    }
}
extension DoclinkResolver
{
    public
    func resolve(_ link:Doclink) -> Int32?
    {
        if !link.absolute,
            let scope:Scope = self.scope
        {
            for index:Int in scope.indices.reversed()
            {
                let path:DoclinkResolutionPath = .join(scope[...index] + link.path)
                if  let address:Int32 = self.table.entries[path]
                {
                    return address
                }
            }
        }
        return self.table.entries[.join(link.path)]
    }
}
