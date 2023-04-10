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
