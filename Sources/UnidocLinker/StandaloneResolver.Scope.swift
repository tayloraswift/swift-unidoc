import ModuleGraphs

extension StandaloneResolver
{
    enum Scope
    {
        case documentation(ModuleIdentifier)
        case tutorials(ModuleIdentifier)
    }
}
extension StandaloneResolver.Scope:RandomAccessCollection
{
    var startIndex:Int { 0 }
    var endIndex:Int { 2 }

    subscript(index:Int) -> String
    {
        switch (index, self)
        {
        case    (1, .documentation):                return "documentation"
        case    (1,     .tutorials):                return "tutorials"
        case    (_, .documentation(let namespace)),
                (_,     .tutorials(let namespace)): return "\(namespace)"
        }
    }
}
