import SwiftSyntax

extension SignatureSyntax
{
    struct ExpandedParameter
    {
        private
        let syntax:FunctionParameterSyntax

        init(syntax:FunctionParameterSyntax, func _:Bool)
        {
            self.syntax = syntax
        }
    }
}
extension SignatureSyntax.ExpandedParameter:SignatureParameterFormat
{
    static
    func += (signature:inout SignatureSyntax.Encoder<Self>, self:Self)
    {
        var named:Bool = false
        for region:Syntax in self.syntax.children(viewMode: .sourceAccurate)
        {
            guard
            let region:TokenSyntax = region.as(TokenSyntax.self)
            else
            {
                signature += region
                continue
            }

            switch region.tokenKind
            {
            case .identifier, .wildcard:
                if  named
                {
                    signature[in: .binding] += region
                }
                else
                {
                    signature[in: .identifier] += region
                    named = true
                }

            case _:
                signature += region
            }
        }
    }
}
