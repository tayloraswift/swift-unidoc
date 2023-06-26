import Codelinks
import Unidoc

extension Codelink.Filter.Objectivity
{
    @inlinable public static
    func ~= (lhs:Self, rhs:Unidoc.Decl.Objectivity?) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.default, .instance?):    return true
        case (.default, nil):           return true
        case (.default, _?):            return false

        case (.instance, .instance?):   return true
        case (.instance, _):            return false

        case (.class, .class?):         return true
        case (.class, _):               return false

        case (.static, .static?):       return true
        case (.static, _):              return false

        case (.global, nil):            return true
        case (.global, _?):             return false

        case (.type, .static?):         return true
        case (.type, .class?):          return true
        case (.type, _):                return false
        }
    }
}
