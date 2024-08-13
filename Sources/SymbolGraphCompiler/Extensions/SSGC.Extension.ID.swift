import Signatures
import Symbols

extension SSGC.Extension
{
    struct ID:Hashable, Sendable
    {
        let conditions:[GenericConstraint<Symbol.Decl>]
        let extendee:Symbol.Decl

        init(extending extendee:Symbol.Decl, where conditions:[GenericConstraint<Symbol.Decl>])
        {
            self.conditions = conditions
            self.extendee = extendee
        }
    }
}
extension SSGC.Extension.ID:Comparable
{
    static func < (a:Self, b:Self) -> Bool
    {
        if  a.extendee < b.extendee
        {
            return true
        }
        else if a.extendee == b.extendee
        {
            return a.conditions.lexicographicallyPrecedes(b.conditions)
        }
        else
        {
            return false
        }
    }
}
