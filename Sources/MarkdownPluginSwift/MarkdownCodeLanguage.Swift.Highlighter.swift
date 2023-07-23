import IDEUtils
import MarkdownABI
import SwiftParser
import SwiftSyntax

extension MarkdownCodeLanguage.Swift
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
extension MarkdownCodeLanguage.Swift.Highlighter:MarkdownCodeHighlighter
{
    public
    func emit(_ text:String, into binary:inout MarkdownBinaryEncoder)
    {
        //  Last I checked, SwiftParser already does this internally in its
        //  ``String``-based parsing API. Since we need to load the original
        //  source text anyway, we might as well use the UTF-8 buffer-based API.
        var text:String = text ; text.withUTF8
        {
            guard let base:UnsafePointer<UInt8> = $0.baseAddress
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

                let context:MarkdownBytecode.Context
                switch span.kind
                {
                case    .none,
                        .editorPlaceholder:         binary += text ; continue

                case    .attribute:                 context = .attribute

                case    .buildConfigId:             context = .directive
                case    .poundDirectiveKeyword:     context = .magic

                case    .lineComment,
                        .blockComment:              context = .comment
                case    .docLineComment,
                        .docBlockComment:           context = .doccomment

                case    .dollarIdentifier:          context = .pseudo
                case    .identifier:                context = .identifier
                case    .operatorIdentifier:        context = .operator

                case    .integerLiteral,
                        .floatingLiteral:           context = .literalNumber
                case    .stringLiteral,
                        .objectLiteral:             context = .literalString

                case    .keyword:                   context = .keyword
                case    .stringInterpolationAnchor: context = .interpolation
                case    .typeIdentifier:            context = .type
                }

                binary[context] { $0 += text }
            }
        }
    }
}
