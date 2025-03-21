import SwiftSyntax

protocol SignatureVisitor
{
    associatedtype Parameter:SignatureParameter

    mutating
    func register(parameter:FunctionParameterSyntax, type:SignatureParameterType) -> Parameter
}
