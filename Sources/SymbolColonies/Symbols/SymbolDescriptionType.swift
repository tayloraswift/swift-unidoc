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
    case  globalFunction    = "swift.func"
    case  globalVariable    = "swift.var"
    case  initializer       = "swift.init"
    case  instanceFunction  = "swift.method"
    case  instanceVariable  = "swift.property"
    case  instanceSubscript = "swift.subscript"
    case  macro             = "swift.macro"
    case `operator`         = "swift.func.op"
    case `protocol`         = "swift.protocol"
    case `struct`           = "swift.struct"
    case `typealias`        = "swift.typealias"
    case  typeFunction      = "swift.type.method"
    case  typeVariable      = "swift.type.property"
    case  typeSubscript     = "swift.type.subscript"
}
