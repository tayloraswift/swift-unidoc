@frozen public 
enum SymbolPhylum:Hashable, Sendable
{
    case  actor
    case `associatedtype`
    case `case`
    case `class`
    case  deinitializer
    case `enum`
    case `extension`
    case `func`(Objectivity?)
    case  initializer
    case  macro
    case `operator`
    case `protocol`
    case `struct`
    case `subscript`(Objectivity)
    case `typealias`
    case `var`(Objectivity?)
}
