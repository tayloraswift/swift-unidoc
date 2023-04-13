@frozen public
enum SymbolObjectivity:Equatable, Hashable, Comparable, Sendable
{
    case instance
    case `class`
    case `static`
}
