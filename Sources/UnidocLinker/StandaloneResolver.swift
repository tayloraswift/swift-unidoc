import Doclinks
import ModuleGraphs

struct StandaloneResolver
{
    private
    var items:[StandaloneArticlePath: Int32]

    init()
    {
        self.items = [:]
    }
}

extension StandaloneResolver
{
    subscript(scope:Scope, name:String) -> Int32?
    {
        _read
        {
            yield  self.items[.join(scope + [name])]
        }
        _modify
        {
            yield &self.items[.join(scope + [name])]
        }
    }
}
extension StandaloneResolver
{
    func query(ascending scope:Scope, link:Doclink) -> Int32?
    {
        if !link.absolute
        {
            for index:Int in scope.indices.reversed()
            {
                let path:StandaloneArticlePath = .join(scope[...index] + link.path)
                if  let address:Int32 = self.items[path]
                {
                    return address
                }
            }
        }
        return self.items[.join(link.path)]
    }
}
