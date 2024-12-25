import SwiftIDEUtils
import SwiftParser
import SwiftSyntax

@frozen @usableFromInline
struct SignatureSyntax
{
    @usableFromInline
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
    @usableFromInline
    func split(on boundaries:[Int]) -> [Span]
    {
        var spans:[SignatureSyntax.Span] = []
            spans.reserveCapacity(self.elements.count)

        var boundaries:IndexingIterator<[Int]> = boundaries.makeIterator()
        var next:Int? = boundaries.next()

        for span:SignatureSyntax.Span in self.elements
        {
            guard case .text(var range, let color, let depth) = span
            else
            {
                spans.append(span)
                continue
            }
            defer
            {
                spans.append(.text(range, color, depth))
            }

            while let split:Int = next
            {
                guard split < range.upperBound
                else
                {
                    break
                }

                defer
                {
                    next = boundaries.next()
                }

                guard range.lowerBound < split
                else
                {
                    continue
                }

                spans.append(.text(range.lowerBound ..< split, color, depth))
                range = split ..< range.upperBound
            }
        }

        return spans
    }
}
extension SignatureSyntax
{
    @usableFromInline static
    func abridged(_ utf8:UnsafeBufferPointer<UInt8>) -> Self
    {
        var encoder:Encoder<AbridgedParameter> = .init()
        var parser:Parser = .init(utf8)

        encoder.encode(decl: .parse(from: &parser))

        return .init(elements: encoder.move())
    }
    @usableFromInline static
    func expanded(_ utf8:UnsafeBufferPointer<UInt8>) -> Self
    {
        var encoder:Encoder<ExpandedParameter> = .init()
        var parser:Parser = .init(utf8)

        encoder.encode(decl: .parse(from: &parser))

        return .init(elements: encoder.move())
    }
}
