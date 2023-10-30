extension CodelinkV4
{
    @frozen public
    enum Filter:String, Equatable, Hashable, Sendable
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
