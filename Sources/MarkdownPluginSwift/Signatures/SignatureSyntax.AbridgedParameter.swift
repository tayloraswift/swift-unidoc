import SwiftSyntax

extension SignatureSyntax
{
    struct AbridgedParameter
    {
        private
        let syntax:FunctionParameterSyntax
        private
        let type:SignatureParameterType

        init(syntax:FunctionParameterSyntax, type:SignatureParameterType)
        {
            self.syntax = syntax
            self.type = type
        }
    }
}
extension SignatureSyntax.AbridgedParameter
{
    private
    var unlabeled:Bool
    {
        if  case .wildcard = self.syntax.firstName.tokenKind
        {
            true
        }
        else if
            case nil = self.syntax.secondName,
            case .subscript = self.type
        {
            true
        }
        else
        {
            false
        }
    }
}
extension SignatureSyntax.AbridgedParameter:SignatureParameter
{
    static
    func += (signature:inout SignatureSyntax.Encoder, self:Self)
    {
        if  self.unlabeled
        {
            signature += self.syntax.type.trimmedPreservingLocation
            signature ?= self.syntax.ellipsis?.trimmedPreservingLocation
            signature ?= self.syntax.trailingComma
        }
        else
        {
            signature[at: .toplevel] += self.syntax.firstName.trimmedPreservingLocation
            signature += self.syntax.colon
            signature += self.syntax.type.trimmedPreservingLocation
            signature ?= self.syntax.ellipsis?.trimmedPreservingLocation
            signature ?= self.syntax.trailingComma
        }
    }
}
