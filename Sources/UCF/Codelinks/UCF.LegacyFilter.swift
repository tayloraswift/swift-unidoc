extension UCF
{
    @frozen public
    enum LegacyFilter:Substring, Equatable, Hashable, Sendable
    {
        case `associatedtype`   = "associatedtype"
        case `enum`             = "enum"
        case  enum_case         = "enum.case"
        case `class`            = "class"
        case `func`             = "func"
        case  func_op           = "func.op"
        case `var`              = "var"
        case `deinit`           = "deinit"
        case `init`             = "init"
        case  method            = "method"
        case  property          = "property"
        case `subscript`        = "subscript"
        case  macro             = "macro"
        case `protocol`         = "protocol"
        case `struct`           = "struct"
        case `typealias`        = "typealias"
        case  type_method       = "type.method"
        case  type_property     = "type.property"
        case  type_subscript    = "type.subscript"
    }
}
