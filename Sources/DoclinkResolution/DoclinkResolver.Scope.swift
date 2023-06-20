import ModuleGraphs

extension DoclinkResolver
{
    @frozen public
    enum Scope
    {
        case documentation(ModuleIdentifier)
        case tutorials(ModuleIdentifier)
    }
}
extension DoclinkResolver.Scope:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int { 0 }
    @inlinable public
    var endIndex:Int { 3 }

    @inlinable public
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
