extension Codelink
{
    @frozen public
    enum Filter:Equatable, Hashable, Sendable
    {
        case  actor
        case `associatedtype`
        case `case`
        case `class`
        case `enum`
        case `func`(Objectivity)
        case  macro
        case `protocol`
        case `struct`
        case `subscript`(Subscript)
        case `typealias`
        case `var`(Objectivity)
    }
}
extension Codelink.Filter
{
    public
    init?(suffix:Substring)
    {
        //  Very similar to the `SymbolDescriptionType` enum in `SymbolColonies`,
        //  except no extensions.
        switch suffix
        {
        case "swift.associatedtype":  self = .associatedtype
        case "swift.enum":            self = .enum
        case "swift.enum.case":       self = .case
        case "swift.class":           self = .class
        case "swift.func":            self = .func(.global)
        case "swift.func.op":         self = .func(.default)
        case "swift.var":             self = .var(.global)
        case "swift.deinit":          return nil
        case "swift.init":            return nil
        case "swift.method":          self = .func(.instance)
        case "swift.property":        self = .var(.instance)
        case "swift.subscript":       self = .subscript(.instance)
        case "swift.macro":           self = .macro
        case "swift.protocol":        self = .protocol
        case "swift.struct":          self = .struct
        case "swift.typealias":       self = .typealias
        case "swift.type.method":     self = .func(.type)
        case "swift.type.property":   self = .var(.type)
        case "swift.type.subscript":  self = .subscript(.type)
        default:                return nil
        }
    }
}
extension Codelink.Filter
{
    var suffix:String?
    {
        switch self
        {
        case .actor:                return "swift.actor"
        case .associatedtype:       return "swift.associatedtype"
        case .case:                 return "swift.enum.case"
        case .class:                return "swift.class"
        case .enum:                 return "swift.enum"
        case .func(.default):       return "swift.func.op"
        case .func(.global):        return "swift.func"
        case .func(.instance):      return "swift.method"
        case .func(.type):          return "swift.type.method"
        case .func(_):              return nil
        case .macro:                return "swift.macro"
        case .protocol:             return "swift.protocol"
        case .struct:               return "swift.struct"
        case .subscript(.instance): return "swift.subscript"
        case .subscript(.type):     return "swift.type.subscript"
        case .subscript(_):         return nil
        case .typealias:            return "swift.typealias"
        case .var(.global):         return "swift.var"
        case .var(.instance):       return "swift.property"
        case .var(.type):           return "swift.type.property"
        case .var(_):               return nil
        }
    }
    var keywords:(first:Codelink.Keyword, second:Codelink.Keyword?)?
    {
        switch self
        {
        case .actor:                return (.actor, nil)
        case .associatedtype:       return (.associatedtype, nil)
        case .case:                 return (.case, nil)
        case .class:                return (.class, nil)
        case .enum:                 return (.enum, nil)
        case .func(.static):        return (.static, .func)
        case .func(.class):         return (.class, .func)
        case .func(_):              return (.func, nil)
        case .macro:                return (.macro, nil)
        case .protocol:             return (.protocol, nil)
        case .struct:               return (.struct, nil)
        case .subscript(.static):   return (.static, nil)
        case .subscript(.class):    return (.class, nil)
        case .subscript(_):         return nil
        case .typealias:            return (.typealias, nil)
        case .var(.static):         return (.static, .var)
        case .var(.class):          return (.class, .var)
        case .var(_):               return (.var, nil)
        }
    }
}
