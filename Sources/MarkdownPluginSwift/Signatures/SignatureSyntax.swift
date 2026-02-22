import SwiftIDEUtils
import SwiftParser
import SwiftSyntax

@frozen @usableFromInline struct SignatureSyntax {
    @usableFromInline let elements: [Span]

    init(elements: [Span]) {
        self.elements = elements
    }
}
extension SignatureSyntax {
    @usableFromInline func split(on boundaries: [Int]) -> [Span] {
        var spans: [SignatureSyntax.Span] = []
        spans.reserveCapacity(self.elements.count)

        var boundaries: IndexingIterator<[Int]> = boundaries.makeIterator()
        var next: Int? = boundaries.next()

        for span: SignatureSyntax.Span in self.elements {
            guard case .text(var range, let color, let depth) = span else {
                spans.append(span)
                continue
            }
            defer {
                spans.append(.text(range, color, depth))
            }

            while let split: Int = next {
                guard split < range.upperBound else {
                    break
                }

                defer {
                    next = boundaries.next()
                }

                guard range.lowerBound < split else {
                    continue
                }

                spans.append(.text(range.lowerBound ..< split, color, depth))
                range = split ..< range.upperBound
            }
        }

        return spans
    }
}
extension SignatureSyntax {
    @usableFromInline static func abridged(_ utf8: UnsafeBufferPointer<UInt8>) -> Self {
        var builder: Builder<AbridgedVisitor> = .init(visitor: .init())
        var parser: Parser = .init(utf8)

        builder.encode(decl: .parse(from: &parser))

        return .init(elements: builder.encoder.move())
    }
    @usableFromInline static func expanded(
        _ utf8: UnsafeBufferPointer<UInt8>,
        sugaring sugarMap: SugarMap,
        landmarks: inout SignatureLandmarks
    ) -> Self {
        var builder: Builder<ExpandedVisitor> = .init(visitor: .init(sugaring: sugarMap))
        var parser: Parser = .init(utf8)

        builder.encode(decl: .parse(from: &parser))

        landmarks.keywords.actor = builder.visitor.actor
        landmarks.keywords.async = builder.visitor.async
        landmarks.keywords.class = builder.visitor.class
        landmarks.keywords.final = builder.visitor.final

        landmarks.inputs = builder.visitor.inputs
        landmarks.output = builder.visitor.output

        return .init(elements: builder.encoder.move())
    }
}
