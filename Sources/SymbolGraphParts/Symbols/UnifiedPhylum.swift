import JSONDecoding
import JSONEncoding
import Symbols

@frozen public 
enum UnifiedPhylum:Hashable, Equatable, Sendable
{
    case block
    case macro
    case scalar(ScalarPhylum)
}
extension UnifiedPhylum:JSONDecodable, JSONStringDecodable
{
    public
    init?(_ description:String)
    {
        switch description
        {
        case "swift.extension":         self = .block
        case "swift.macro":             self = .macro
        case "swift.associatedtype":    self = .scalar(.associatedtype)
        case "swift.enum":              self = .scalar(.enum)
        case "swift.enum.case":         self = .scalar(.case)
        case "swift.class":             self = .scalar(.class)
        case "swift.deinit":            self = .scalar(.deinitializer)
        case "swift.func":              self = .scalar(.func(nil))
        case "swift.var":               self = .scalar(.var(nil))
        case "swift.init":              self = .scalar(.initializer)
        case "swift.method":            self = .scalar(.func(.instance))
        case "swift.property":          self = .scalar(.var(.instance))
        case "swift.subscript":         self = .scalar(.subscript(.instance))
        case "swift.func.op":           self = .scalar(.operator)
        case "swift.protocol":          self = .scalar(.protocol)
        case "swift.struct":            self = .scalar(.struct)
        case "swift.typealias":         self = .scalar(.typealias)
        case "swift.type.method":       self = .scalar(.func(.static))
        case "swift.type.property":     self = .scalar(.var(.static))
        case "swift.type.subscript":    self = .scalar(.subscript(.static))
        default:                        return nil
        }
    }
}
