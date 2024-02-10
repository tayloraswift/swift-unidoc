import MarkdownABI
import SwiftIDEUtils
import SwiftParser
import SwiftSyntax

extension Markdown.SwiftLanguage
{
    @frozen public
    struct Highlighter
    {
        @inlinable public
        init()
        {
        }
    }
}
extension Markdown.SwiftLanguage.Highlighter:Markdown.CodeHighlighter
{
    public
    func emit(_ text:consuming String, into binary:inout Markdown.BinaryEncoder)
    {
        //  Last I checked, SwiftParser already does this internally in its
        //  ``String``-based parsing API. Since we need to load the original
        //  source text anyway, we might as well use the UTF-8 buffer-based API.
        text.withUTF8
        {
            guard
            let base:UnsafePointer<UInt8> = $0.baseAddress
            else
            {
                return // empty string
            }
            let parsed:SourceFileSyntax = Parser.parse(source: $0)
            for span:SyntaxClassifiedRange in parsed.classifications
            {
                let text:UnsafeBufferPointer<UInt8> = .init(
                    start: base + span.offset,
                    count: span.length)

                binary[highlight: span.kind] = text
            }
        }
    }
}
