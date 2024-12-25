import SwiftSyntax

extension SignatureSyntax
{
    struct ExpandedVisitor
    {
    }
}
extension SignatureSyntax.ExpandedVisitor:SignatureVisitor
{
    mutating
    func register(
        parameter:FunctionParameterSyntax,
        type _:SignatureParameterType) -> SignatureSyntax.ExpandedParameter
    {
        .init(syntax: parameter)
    }

    mutating
    func register(returns:TypeSyntax)
    {
    }
}
