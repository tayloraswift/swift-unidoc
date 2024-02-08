import MarkdownABI
import MarkdownRendering
import SwiftIDEUtils
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

extension MarkdownCodeLanguage.Swift.Highlighter
{
    public
    func _parse(snippet utf8:[UInt8])
    {
        //  It is safe to escape the pointer to ``Parser.parse(source:maximumNestingLevel:)``,
        //  see: https://swiftinit.org/docs/swift-syntax/swiftparser/parser.init(_:maximumnestinglevel:parsetransition:arena:)
        let parsed:SourceFileSyntax = utf8.withUnsafeBufferPointer
        {
            Parser.parse(source: $0)
        }
        var start:AbsolutePosition = parsed.position
        var text:String = ""
        lines:
        for piece:TriviaPiece in parsed.leadingTrivia
        {
            let line:String
            let skip:Int
            switch piece
            {
            case .lineComment(let text):
                start += piece.sourceLength
                line = text
                skip = 2

            case .docLineComment(let text):
                start += piece.sourceLength
                line = text
                skip = 3

            case .newlines(1), .carriageReturnLineFeeds(1):
                start += piece.sourceLength
                continue

            case .newlines, .carriageReturnLineFeeds:
                start += piece.sourceLength
                break lines

            default:
                break lines
            }

            guard
            let i:String.Index = line.index(line.startIndex,
                offsetBy: skip,
                limitedBy: line.endIndex)
            else
            {
                fatalError("Encountered a line comment with no leading slashes!")
            }

            text += line[i...].drop(while: \.isWhitespace)
            text.append("\n")
        }

        var parser:SnippetParser = .init(start: start)
        for token:TokenSyntax in parsed.tokens(viewMode: .sourceAccurate)
        {
            parser.visit(token: token)
        }

        let slices:[SnippetParser.Slice] = parser.finish(at: parsed.endPosition, in: utf8)

        var spans:SyntaxClassifications.Iterator = parsed.classifications.makeIterator()
        var span:SyntaxClassifiedRange? = spans.next()
        let rendered:[MarkdownBytecode] = slices.map
        {
            (slice:SnippetParser.Slice) in .init
            {
                ranges:
                for var range:Range<Int> in slice.ranges
                {
                    while let highlight:SyntaxClassifiedRange = span
                    {
                        if  range.upperBound < highlight.endOffset
                        {
                            //  This range is strictly contained within the current highlight.
                            $0[highlight: highlight.kind] = utf8[range]
                            continue ranges
                        }

                        span = spans.next()

                        if  range.lowerBound >= highlight.endOffset
                        {
                            //  This range does not overlap with the current highlight at all.
                            continue
                        }

                        if  range.upperBound == highlight.endOffset
                        {
                            //  This range ends at the end of the current highlight.
                            $0[highlight: highlight.kind] = utf8[range]
                            continue ranges
                        }
                        else
                        {
                            //  This range ends after the end of the current highlight.
                            let overlap:Range<Int> = range.lowerBound ..< highlight.endOffset
                            $0[highlight: highlight.kind] = utf8[overlap]

                            range = highlight.endOffset ..< range.upperBound
                        }
                    }
                }
            }
        }

        for (slice, rendered):(SnippetParser.Slice, MarkdownBytecode) in zip(slices, rendered)
        {
            print("Snippet '\(slice.id)':")
            print("--------------------")
            print("\(rendered.safe)")
            print("--------------------")
        }
    }
}
extension MarkdownCodeLanguage.Swift.Highlighter:MarkdownCodeHighlighter
{
    public
    func emit(_ text:consuming String, into binary:inout MarkdownBinaryEncoder)
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
