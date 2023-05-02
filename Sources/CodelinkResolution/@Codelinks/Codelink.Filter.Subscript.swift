import Codelinks
import Symbolics

extension Codelink.Filter.Subscript
{
    @inlinable public static
    func ~= (lhs:Self, rhs:ScalarPhylum.Objectivity) -> Bool
    {
        switch (lhs, rhs)
        {
        case (.instance, .instance):    return true
        case (.instance, _):            return false

        case (.class, .class):          return true
        case (.class, _):               return false

        case (.static, .static):        return true
        case (.static, _):              return false

        case (.type, .static):          return true
        case (.type, .class):           return true
        case (.type, _):                return false
        }
    }
}
