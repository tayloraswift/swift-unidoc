import SwiftSyntax

extension SignatureSyntax
{
    struct AbridgedVisitor
    {
    }
}
extension SignatureSyntax.AbridgedVisitor:SignatureVisitor
{
    mutating
    func register(
        parameter:FunctionParameterSyntax,
        type:SignatureParameterType) -> SignatureSyntax.AbridgedParameter
    {
        .init(syntax: parameter, type: type)
    }
}
