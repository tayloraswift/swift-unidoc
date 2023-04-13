import JSONDecoding
import JSONEncoding

extension SymbolDescription
{
    @frozen public 
    enum Phylum:Hashable, Sendable
    {
        case  actor
        case `associatedtype`
        case `case`
        case `class`
        case  deinitializer
        case `enum`
        case `extension`
        case `func`(SymbolObjectivity?)
        case  initializer
        case  macro
        case `operator`
        case `protocol`
        case `struct`
        case `subscript`(SymbolObjectivity)
        case `typealias`
        case `var`(SymbolObjectivity?)
    }
}
extension SymbolDescription.Phylum:JSONDecodable, JSONStringDecodable
{
    public
    init?(_ description:String)
    {
        switch description
        {
        case "swift.associatedtype":    self = .associatedtype
        case "swift.enum":              self = .enum
        case "swift.extension":         self = .extension
        case "swift.enum.case":         self = .case
        case "swift.class":             self = .class
        case "swift.deinit":            self = .deinitializer
        case "swift.func":              self = .func(nil)
        case "swift.var":               self = .var(nil)
        case "swift.init":              self = .initializer
        case "swift.method":            self = .func(.instance)
        case "swift.property":          self = .var(.instance)
        case "swift.subscript":         self = .subscript(.instance)
        case "swift.macro":             self = .macro
        case "swift.func.op":           self = .operator
        case "swift.protocol":          self = .protocol
        case "swift.struct":            self = .struct
        case "swift.typealias":         self = .typealias
        case "swift.type.method":       self = .func(.static)
        case "swift.type.property":     self = .var(.static)
        case "swift.type.subscript":    self = .subscript(.static)
        default:                        return nil
        }
    }
}
