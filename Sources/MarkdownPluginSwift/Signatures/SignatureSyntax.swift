import SwiftIDEUtils
import SwiftParser
import SwiftSyntax

@frozen @usableFromInline internal
struct SignatureSyntax
{
    @usableFromInline internal
    let elements:[Span]

    private
    init(elements:[Span])
    {
        self.elements = elements
    }
}
extension SignatureSyntax
{
    private
    init<Format>(utf8:UnsafeBufferPointer<UInt8>, format:Format.Type)
        where Format:SignatureParameterFormat
    {
        var encoder:Encoder<Format> = .init()
        var parser:Parser = .init(utf8)

        encoder += DeclSyntax.parse(from: &parser)

        self.init(elements: encoder.move())
    }
}
extension SignatureSyntax
{
    @usableFromInline internal static
    func abridged(_ utf8:UnsafeBufferPointer<UInt8>) -> Self
    {
        var encoder:Encoder<AbridgedParameter> = .init()
        var parser:Parser = .init(utf8)

        encoder += DeclSyntax.parse(from: &parser)

        return .init(elements: encoder.move())
    }
    @usableFromInline internal static
    func expanded(_ utf8:UnsafeBufferPointer<UInt8>) -> Self
    {
        var encoder:Encoder<ExpandedParameter> = .init()
        var parser:Parser = .init(utf8)

        encoder += DeclSyntax.parse(from: &parser)

        return .init(elements: encoder.move())
    }
}
