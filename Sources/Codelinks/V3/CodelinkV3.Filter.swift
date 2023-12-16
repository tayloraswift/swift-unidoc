extension CodelinkV3
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
        case  module
        case `protocol`
        case `struct`
        case `subscript`(Subscript)
        case `typealias`
        case `var`(Objectivity)
    }
}
extension CodelinkV3.Filter
{
    public
    init?(suffix:Substring)
    {
        //  Very similar to the `Phylum` type, except no extensions.
        switch suffix
        {
        case "swift.associatedtype":    self = .associatedtype
        case "swift.enum":              self = .enum
        case "swift.enum.case":         self = .case
        case "swift.class":             self = .class
        case "swift.func":              self = .func(.global)
        case "swift.func.op":           self = .func(.default)
        case "swift.var":               self = .var(.global)
        case "swift.deinit":            return nil
        case "swift.init":              return nil
        case "swift.method":            self = .func(.instance)
        case "swift.property":          self = .var(.instance)
        case "swift.subscript":         self = .subscript(.instance)
        case "swift.macro":             self = .macro
        case "swift.protocol":          self = .protocol
        case "swift.struct":            self = .struct
        case "swift.typealias":         self = .typealias
        case "swift.type.method":       self = .func(.type)
        case "swift.type.property":     self = .var(.type)
        case "swift.type.subscript":    self = .subscript(.type)
        default:                        return nil
        }
    }
}
extension CodelinkV3.Filter
{
    var suffix:String?
    {
        switch self
        {
        case .actor:                "swift.actor"
        case .associatedtype:       "swift.associatedtype"
        case .case:                 "swift.enum.case"
        case .class:                "swift.class"
        case .enum:                 "swift.enum"
        case .func(.default):       "swift.func.op"
        case .func(.global):        "swift.func"
        case .func(.instance):      "swift.method"
        case .func(.type):          "swift.type.method"
        case .func(_):              nil
        case .macro:                "swift.macro"
        case .module:               nil
        case .protocol:             "swift.protocol"
        case .struct:               "swift.struct"
        case .subscript(.instance): "swift.subscript"
        case .subscript(.type):     "swift.type.subscript"
        case .subscript(_):         nil
        case .typealias:            "swift.typealias"
        case .var(.global):         "swift.var"
        case .var(.instance):       "swift.property"
        case .var(.type):           "swift.type.property"
        case .var(_):               nil
        }
    }
    var keywords:(first:CodelinkV3.Keyword, second:CodelinkV3.Keyword?)?
    {
        switch self
        {
        case .actor:                (.actor, nil)
        case .associatedtype:       (.associatedtype, nil)
        case .case:                 (.case, nil)
        case .class:                (.class, nil)
        case .enum:                 (.enum, nil)
        case .func(.static):        (.static, .func)
        case .func(.class):         (.class, .func)
        case .func(_):              (.func, nil)
        case .macro:                (.macro, nil)
        case .module:               (.import, nil)
        case .protocol:             (.protocol, nil)
        case .struct:               (.struct, nil)
        case .subscript(.static):   (.static, nil)
        case .subscript(.class):    (.class, nil)
        case .subscript(_):         nil
        case .typealias:            (.typealias, nil)
        case .var(.static):         (.static, .var)
        case .var(.class):          (.class, .var)
        case .var(_):               (.var, nil)
        }
    }
}
