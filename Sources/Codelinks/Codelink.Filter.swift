extension CodelinkV4
{
    @frozen public
    enum Filter:Substring, Equatable, Hashable, Sendable
    {
        case  actor             = "actor"
        case `associatedtype`   = "associatedtype"
        case `enum`             = "enum"
        case `case`             = "case"
        case `class`            = "class"
        case  class_func        = "class func"
        case  class_subscript   = "class subscript"
        case  class_var         = "class var"
        case `deinit`           = "deinit"
        case `func`             = "func"
        case `init`             = "init"
        case  macro             = "macro"
        case `protocol`         = "protocol"
        case  static_func       = "static func"
        case  static_subscript  = "static subscript"
        case  static_var        = "static var"
        case `struct`           = "struct"
        case `subscript`        = "subscript"
        case `typealias`        = "typealias"
        case `var`              = "var"
    }
}
extension CodelinkV4.Filter
{
    @inlinable public
    init?(legacy:CodelinkV4.Suffix.Legacy.Filter)
    {
        switch legacy
        {
        case .associatedtype:   self = .associatedtype
        case .enum:             self = .enum
        case .enum_case:        self = .case
        case .class:            return nil
        case .func:             return nil
        case .func_op:          return nil
        case .var:              return nil
        case .deinit:           self = .deinit
        case .`init`:           self = .`init`
        case .method:           return nil
        case .property:         return nil
        case .subscript:        self = .subscript
        case .macro:            self = .macro
        case .protocol:         self = .protocol
        case .struct:           self = .struct
        case .typealias:        self = .typealias
        case .type_method:      return nil
        case .type_property:    return nil
        case .type_subscript:   return nil
        }
    }
}
extension CodelinkV4.Filter:CustomStringConvertible
{
    @inlinable public
    var description:String { .init(self.rawValue) }
}
extension CodelinkV4.Filter:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description[...])
    }

    @inlinable public
    init?(_ description:Substring)
    {
        self.init(rawValue: description)
    }
}
