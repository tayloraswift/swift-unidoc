import SwiftIDEUtils
import SwiftSyntax

extension SignatureSyntax
{
    struct Encoder:~Copyable
    {
        private
        var spans:[Span]

        /// An override for the color of the next span.
        private
        var color:Markdown.Bytecode.Context?
        /// The depth level used to encode the next span.
        private
        var depth:Span.Depth?

        init(spans:[Span] = [],
            color:Markdown.Bytecode.Context? = nil,
            depth:Span.Depth? = nil)
        {
            self.spans = spans
            self.color = color
            self.depth = depth
        }
    }
}
extension SignatureSyntax.Encoder
{
    consuming
    func move() -> [SignatureSyntax.Span] { self.spans }

    mutating
    func wbr(indent:Bool)
    {
        self.spans.append(.wbr(indent: indent))
    }
}
extension SignatureSyntax.Encoder
{
    subscript(in color:Markdown.Bytecode.Context) -> Self
    {
        get
        {
            .init(spans: self.spans,
                color: color,
                depth: self.depth)
        }
        _modify
        {
            let outer:Markdown.Bytecode.Context? = self.color
            self.color = color
            defer { self.color = outer }

            yield &self
        }
    }
    subscript(at depth:SignatureSyntax.Span.Depth) -> Self
    {
        get
        {
            .init(spans: self.spans,
                color: self.color,
                depth: depth)
        }
        _modify
        {
            let outer:SignatureSyntax.Span.Depth? = self.depth
            self.depth = depth
            defer { self.depth = outer }

            yield &self
        }
    }
}
extension SignatureSyntax.Encoder
{
    static
    func ?= (self:inout Self, syntax:(some SyntaxProtocol)?)
    {
        syntax.map { self += $0 }
    }
    static
    func += (self:inout Self, syntax:some SyntaxProtocol)
    {
        for span:SyntaxClassifiedRange in syntax.classifications
        {
            let range:Range<Int> = span.offset ..< span.offset + span.length
            let color:Markdown.Bytecode.Context? = .init(classification: span.kind)

            self.spans.append(.text(range, color.map { self.color ?? $0 }, self.depth))
        }
    }
}
