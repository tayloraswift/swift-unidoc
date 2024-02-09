import SwiftSyntax

extension SignatureSyntax
{
    struct AbridgedParameter
    {
        private
        let syntax:FunctionParameterSyntax
        private
        let `func`:Bool

        init(syntax:FunctionParameterSyntax, func:Bool)
        {
            self.syntax = syntax
            self.func = `func`
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
            case false = self.func
        {
            true
        }
        else
        {
            false
        }
    }
}
extension SignatureSyntax.AbridgedParameter:SignatureParameterFormat
{
    static
    func += (signature:inout SignatureSyntax.Encoder<Self>, self:Self)
    {
        if  self.unlabeled
        {
            signature += self.syntax.type.trimmed
            signature ?= self.syntax.ellipsis?.trimmed
            signature ?= self.syntax.trailingComma
        }
        else
        {
            signature[at: .toplevel] += self.syntax.firstName.trimmed
            signature += self.syntax.colon
            signature += self.syntax.type.trimmed
            signature ?= self.syntax.ellipsis?.trimmed
            signature ?= self.syntax.trailingComma
        }
    }
}
