import JSONDecoding
import JSONEncoding

enum SymbolDescriptionType:String, JSONDecodable, JSONEncodable
{
    case `associatedtype`   = "swift.associatedtype"
    case `enum`             = "swift.enum"
    case `extension`        = "swift.extension"
    case `case`             = "swift.enum.case"
    case `class`            = "swift.class"
    case  deinitializer     = "swift.deinit"
    case `func`             = "swift.func"
    case  initializer       = "swift.init"
    case  instanceMethod    = "swift.method"
    case  instanceProperty  = "swift.property"
    case  instanceSubscript = "swift.subscript"
    case  macro             = "swift.macro"
    case `operator`         = "swift.func.op"
    case `protocol`         = "swift.protocol"
    case `struct`           = "swift.struct"
    case `typealias`        = "swift.typealias"
    case  typeMethod        = "swift.type.method"
    case  typeProperty      = "swift.type.property"
    case  typeSubscript     = "swift.type.subscript"
    case `var`              = "swift.var"
}
