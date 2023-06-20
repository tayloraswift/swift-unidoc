import Doclinks
import ModuleGraphs

@frozen public
struct DoclinkResolver
{
    @usableFromInline internal
    var entries:[DoclinkResolutionPath: Int32]

    @inlinable public
    init()
    {
        self.entries = [:]
    }
}
extension DoclinkResolver
{
    @inlinable public
    subscript(scope:Scope, name:String) -> Int32?
    {
        _read
        {
            yield  self.entries[.join(scope + [name])]
        }
        _modify
        {
            yield &self.entries[.join(scope + [name])]
        }
    }
}
extension DoclinkResolver
{
    public
    func query(ascending scope:Scope, link:Doclink) -> Int32?
    {
        if !link.absolute
        {
            for index:Int in scope.indices.reversed()
            {
                let path:DoclinkResolutionPath = .join(scope[...index] + link.path)
                if  let address:Int32 = self.entries[path]
                {
                    return address
                }
            }
        }
        return self.entries[.join(link.path)]
    }
}
