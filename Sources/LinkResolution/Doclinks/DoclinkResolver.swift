import UCF
import Symbols

@frozen public
struct DoclinkResolver
{
    public
    let table:Table
    public
    let scope:Scope

    @inlinable public
    init(table:Table, scope:Scope)
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
        if !link.absolute
        {
            if  let namespace:Symbol.Module = self.scope.namespace
            {
                for prefix:Prefix in [.documentation(namespace), .tutorials(namespace)]
                {
                    for index:Int in prefix.indices.reversed()
                    {
                        let path:DoclinkResolutionPath = .join(prefix[...index] + link.path)
                        if  let address:Int32 = self.table.entries[path]
                        {
                            return address
                        }
                    }
                }
            }
        }
        return self.table.entries[.join(link.path)]
    }

    public
    func resolve(_ doclink:Doclink, docc:Bool) -> Int32?
    {
        if  let resolved:Int32 = self.resolve(doclink)
        {
            return resolved
        }

        guard docc,
        let namespace:Symbol.Module = self.scope.namespace
        else
        {
            return nil
        }

        //  You really have to wonder what the hell the [people] at Apple were thinking...
        let prefix:Prefix
        switch (doclink.absolute, doclink.path.first)
        {
        case (false, "tutorials"?):     prefix = .tutorials(namespace)
        case (false, "documentation"?): prefix = .documentation(namespace)
        default:                        return nil
        }

        let path:DoclinkResolutionPath = .join([_].init(prefix) + doclink.path.dropFirst())
        return self.table.entries[path]
    }
}
