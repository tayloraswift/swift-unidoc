import Signatures
import SymbolGraphParts
import Symbols

extension SSGC
{
    struct ExtensionSignatureError:Error
    {
        let expected:ExtensionSignature
        let declared:[GenericConstraint<Symbol.Decl>]?

        init(expected:ExtensionSignature,
            declared:[GenericConstraint<Symbol.Decl>]? = nil)
        {
            self.expected = expected
            self.declared = declared
        }
    }
}
extension SSGC.ExtensionSignatureError:CustomStringConvertible
{
    var description:String
    {
        if  let _:[GenericConstraint<Symbol.Decl>] = self.declared
        {
            """
            Cannot declare an extension (of \(self.expected.extendee)) containing \
            a symbol with different extension constraints than its extension block.
            """
        }
        else
        {
            """
            Cannot declare an extension (of \(self.expected.extendee)) containing \
            a relationship with different extension constraints than its extension \
            block.
            """
        }
    }
}
