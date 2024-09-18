import Signatures
import SymbolGraphParts
import Symbols

extension SSGC
{
    enum ExtensionSignatureError:Error
    {
        case conformance(expected:ExtensionSignature, declared:[GenericConstraint<Symbol.Decl>])
        case member     (expected:ExtensionSignature, declared:[GenericConstraint<Symbol.Decl>])
    }
}
extension SSGC.ExtensionSignatureError:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .conformance(expected: let expected, declared: let declared):
            """
            Cannot declare an extension (of \(expected.extendee)) containing \
            a relationship with different extension constraints than its extension \
            block.

            Extension block: \(expected.conditions.humanReadable)
            Relationship: \(declared.humanReadable)
            """
        case .member(expected: let expected, declared: let declared):
            """
            Cannot declare an extension (of \(expected.extendee)) containing \
            a symbol with different extension constraints than its extension block!

            Extension block: \(expected.conditions.humanReadable)
            Extension member: \(declared.humanReadable)
            """
        }
    }
}
