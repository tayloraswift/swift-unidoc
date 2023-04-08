extension SymbolPhylum
{
    @frozen public
    enum Filter:Equatable, Hashable, Sendable
    {
        case  actor
        case `associatedtype`
        case `case`
        case `class`
        case `enum`
        case `func`(ObjectivityFilter?)
        case  initializer
        case `protocol`
        case `struct`
        case `subscript`(ObjectivityFilter?)
        case `typealias`
        case `var`(ObjectivityFilter?)
    }
}
extension SymbolPhylum.Filter
{
    @inlinable public
    init?(_ keyword:SymbolPhylum.Keyword, _ next:Substring)
    {
        switch (keyword, next)
        {
        case (.static, "func"):         self = .func(.static)
        case (.static, "subscript"):    self = .subscript(.static)
        case (.static, "var"):          self = .var(.static)
        case (.class, "func"):          self = .func(.class)
        case (.class, "subscript"):     self = .subscript(.class)
        case (.class, "var"):           self = .var(.class)
        default:                        return nil
        }
    }
    @inlinable public
    init?(_ keyword:SymbolPhylum.Keyword)
    {
        switch keyword
        {
        case .actor:            self = .actor
        case .associatedtype:   self = .associatedtype
        case .case:             self = .case
        case .class:            self = .class
        case .enum:             self = .enum
        case .func:             self = .func(nil)
        case .`init`:           self = .initializer
        case .protocol:         self = .protocol
        case .static:           return nil
        case .struct:           self = .struct
        case .subscript:        self = .subscript(nil)
        case .typealias:        self = .typealias
        case .var:              self = .var(nil)
        }
    }
}
