@frozen public 
enum SymbolPhylum:Hashable, Comparable, Sendable
{
    case  actor
    case `associatedtype`
    case `case`
    case `class`
    case  deinitializer
    case `enum`
    case `func`
    case  initializer
    case  instanceMethod
    case  instanceProperty
    case  instanceSubscript
    case `operator`
    case `protocol`
    case `struct`
    case `typealias`
    case  typeMethod
    case  typeOperator
    case  typeProperty
    case  typeSubscript
    case `var`
}
