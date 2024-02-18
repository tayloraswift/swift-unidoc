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
        switch self
        {
        case .documentation(let namespace):
            switch index
            {
            case 0: "\(namespace)"
            case 1: "documentation"
            case _: "\(namespace)"
            }

        case .tutorials(let namespace):
            switch index
            {
            case 0: "\(namespace)"
            case 1: "documentation"
            case _: "tutorials"
            }
        }
    }
}
