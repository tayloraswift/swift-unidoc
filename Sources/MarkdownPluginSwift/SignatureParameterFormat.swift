import SwiftSyntax

protocol SignatureParameterFormat
{
    init(syntax:FunctionParameterSyntax, func:Bool)

    static
    func += (signature:inout SignatureSyntax.Encoder<Self>, self:Self)
}
