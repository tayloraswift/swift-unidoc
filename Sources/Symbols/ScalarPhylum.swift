@frozen public
enum ScalarPhylum:Hashable, Sendable
{
    case  actor
    case `associatedtype`
    case `case`
    case `class`
    case  deinitializer
    case `enum`
    case `func`(Objectivity?)
    case  initializer
    case `operator`
    case `protocol`
    case `struct`
    case `subscript`(Objectivity)
    case `typealias`
    case `var`(Objectivity?)
}
