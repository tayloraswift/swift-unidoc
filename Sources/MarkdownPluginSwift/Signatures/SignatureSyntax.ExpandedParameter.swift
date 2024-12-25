import SwiftSyntax

extension SignatureSyntax
{
    struct ExpandedParameter
    {
        private
        let syntax:FunctionParameterSyntax

        init(syntax:FunctionParameterSyntax)
        {
            self.syntax = syntax
        }
    }
}
extension SignatureSyntax.ExpandedParameter:SignatureParameter
{
    static
    func += (signature:inout SignatureSyntax.Encoder, self:Self)
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
