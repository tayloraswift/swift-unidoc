import JSONDecoding
import Unidoc

extension Unidoc.Phylum:JSONDecodable, JSONStringDecodable
{
    public
    init?(_ description:String)
    {
        switch description
        {
        case "swift.extension":         self = .block
        case "swift.macro":             self = .macro
        case "swift.associatedtype":    self = .decl(.associatedtype)
        case "swift.enum":              self = .decl(.enum)
        case "swift.enum.case":         self = .decl(.case)
        case "swift.class":             self = .decl(.class)
        case "swift.deinit":            self = .decl(.deinitializer)
        case "swift.func":              self = .decl(.func(nil))
        case "swift.var":               self = .decl(.var(nil))
        case "swift.init":              self = .decl(.initializer)
        case "swift.method":            self = .decl(.func(.instance))
        case "swift.property":          self = .decl(.var(.instance))
        case "swift.subscript":         self = .decl(.subscript(.instance))
        case "swift.func.op":           self = .decl(.operator)
        case "swift.protocol":          self = .decl(.protocol)
        case "swift.struct":            self = .decl(.struct)
        case "swift.typealias":         self = .decl(.typealias)
        case "swift.type.method":       self = .decl(.func(.static))
        case "swift.type.property":     self = .decl(.var(.static))
        case "swift.type.subscript":    self = .decl(.subscript(.static))
        default:                        return nil
        }
    }
}
