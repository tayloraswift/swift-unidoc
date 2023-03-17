import JSONDecoding
import JSONEncoding

enum SymbolDescriptionType:String, JSONDecodable, JSONEncodable
{
    case `protocol`         = "swift.protocol"
    case `associatedtype`   = "swift.associatedtype"
    case `enum`             = "swift.enum"
    case `struct`           = "swift.struct"
    case `class`            = "swift.class"
    case `case`             = "swift.enum.case"
    case initializer        = "swift.init"
    case deinitializer      = "swift.deinit"
    case instanceMethod     = "swift.method"
    case instanceProperty   = "swift.property"
    case instanceSubscript  = "swift.subscript"
    case typeMethod         = "swift.type.method"
    case typeProperty       = "swift.type.property"
    case typeSubscript      = "swift.type.subscript"
    case `operator`         = "swift.func.op"
    case `func`             = "swift.func"
    case `var`              = "swift.var"
    case `typealias`        = "swift.typealias"
    case `extension`        = "swift.extension"
}
