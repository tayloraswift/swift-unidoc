extension SymbolPhylum
{
    @frozen public
    enum Filter:Equatable, Hashable, Sendable
    {
        case  actor
        case `associatedtype`
        case `case`
        case `class`
        case  deinitializer
        case `enum`
        case `func`(ObjectivityFilter)
        case  initializer
        case  macro
        case `protocol`
        case `struct`
        case `subscript`(ObjectivityFilter)
        case `typealias`
        case `var`(ObjectivityFilter)
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
        case (.static, "var"):          self = .var(.static)
        case (.class, "func"):          self = .func(.class)
        case (.class, "var"):           self = .var(.class)
        default:                        return nil
        }
    }
    @inlinable public
    init?(_ keyword:SymbolPhylum.Keyword)
    {
        //  Not possible to use keywords to specify a subscript, init, or deinit
        //  filter.
        switch keyword
        {
        case .actor:            self = .actor
        case .associatedtype:   self = .associatedtype
        case .case:             self = .case
        case .class:            self = .class
        case .enum:             self = .enum
        case .func:             self = .func(.default)
        case .macro:            self = .macro
        case .protocol:         self = .protocol
        case .static:           return nil
        case .struct:           self = .struct
        case .typealias:        self = .typealias
        case .var:              self = .var(.default)
        }
    }
    public
    init?(suffix:Substring)
    {
        //  Very similar to the `SymbolDescriptionType` enum in `SymbolColonies`,
        //  except no extensions.
        switch suffix
        {
        case "associatedtype":  self = .associatedtype
        case "enum":            self = .enum
        case "enum.case":       self = .case
        case "class":           self = .class
        case "func":            self = .func(.global)
        case "func.op":         self = .func(.default)
        case "var":             self = .var(.global)
        case "deinit":          self = .deinitializer
        case "init":            self = .initializer
        case "method":          self = .func(.instance)
        case "property":        self = .var(.instance)
        case "subscript":       self = .subscript(.instance)
        case "macro":           self = .macro
        case "protocol":        self = .protocol
        case "struct":          self = .struct
        case "typealias":       self = .typealias
        case "type.method":     self = .func(.type)
        case "type.property":   self = .var(.type)
        case "type.subscript":  self = .subscript(.type)
        default:                return nil
        }
    }
}
