import Signatures
import Symbols

extension Sequence<GenericConstraint<Symbol.Decl>>
{
    var humanReadable:String
    {
        var string:String = ""
        for clause:GenericConstraint<Symbol.Decl> in self
        {
            if !string.isEmpty
            {
                string += ", "
            }

            switch clause
            {
            case .where(let parameter, is: let what, to: let type):
                string += "\(parameter) \(what.token) \(type.spelling)"
            }
        }
        return string
    }
}
