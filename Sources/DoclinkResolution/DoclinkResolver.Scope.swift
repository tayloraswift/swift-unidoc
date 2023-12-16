import Symbols

extension DoclinkResolver
{
    @frozen public
    enum Scope
    {
        case documentation(Symbol.Module)
        case tutorials(Symbol.Module)
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
        case    (1, .documentation):                "documentation"
        case    (1,     .tutorials):                "tutorials"
        case    (_, .documentation(let namespace)),
                (_,     .tutorials(let namespace)): "\(namespace)"
        }
    }
}
