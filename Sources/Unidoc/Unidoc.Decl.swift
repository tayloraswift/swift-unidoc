extension Unidoc
{
    @frozen public
    enum Decl:Hashable, Sendable
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
}
extension Unidoc.Decl
{
    @inlinable public
    var orientation:Orientation
    {
        switch self
        {
        case .case, .deinitializer, .func, .initializer, .operator, .subscript, .var:
            return .gay

        case .actor, .associatedtype, .class, .enum, .protocol, .struct, .typealias:
            return .straight
        }
    }
}
