import SymbolColonies

extension Compiler
{
    public
    enum ExtensionSignatureError:Equatable, Error
    {
        case conformance(SymbolRelationship.Conformance,
            expected:ExtensionSignature)
        
        case membership(SymbolRelationship.Membership,
            expected:ExtensionSignature,
            declared:[GenericConstraint<ScalarSymbolResolution>])
    }
}
extension Compiler.ExtensionSignatureError:CustomStringConvertible
{
    public
    var description:String
    {
        switch self
        {
        case .conformance(let conformance, expected: let signature):
            return """
            Cannot declare an external conformance (of '\(conformance.source)' to \
            '\(signature.type)') with different generic constraints than its \
            extension block ('\(conformance.target)').
            """
        case .membership(let membership, expected: let signature, declared: _):
            return """
            Cannot declare an external membership (of '\(membership.source)' in \
            '\(signature.type)') with different generic constraints than its \
            extension block ('\(membership.target)').
            """
        }
    }
}
