import Unidoc

extension Unidoc.Decl
{
    var title:String
    {
        switch self
        {
        case .actor:                return "Actor"
        case .associatedtype:       return "Associated Type"
        case .case:                 return "Enumeration Case"
        case .class:                return "Class"
        case .deinitializer:        return "Deinitializer"
        case .enum:                 return "Enumeration"
        case .func(nil):            return "Global Function"
        case .func(.class):         return "Class Method"
        case .func(.instance):      return "Instance Method"
        case .func(.static):        return "Static Method"
        case .initializer:          return "Initializer"
        case .operator:             return "Operator"
        case .protocol:             return "Protocol"
        case .struct:               return "Structure"
        case .subscript(.class):    return "Class Subscript"
        case .subscript(.instance): return "Instance Subscript"
        case .subscript(.static):   return "Static Subscript"
        case .typealias:            return "Type Alias"
        case .var(nil):             return "Global Variable"
        case .var(.class):          return "Class Property"
        case .var(.instance):       return "Instance Property"
        case .var(.static):         return "Static Property"
        }
    }
}
