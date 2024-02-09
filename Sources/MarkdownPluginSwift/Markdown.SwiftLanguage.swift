import MarkdownABI
import Snippets
import SwiftIDEUtils
import SwiftParser
import SwiftSyntax

extension Markdown
{
    @frozen public
    struct SwiftLanguage
    {
        @inlinable internal
        init()
        {
        }
    }
}
extension Markdown.SwiftLanguage:Markdown.CodeLanguageType
{
    @inlinable public
    var name:String { "swift" }

    @inlinable public
    var highlighter:Highlighter { .init() }
}
extension Markdown.SwiftLanguage
{
    public
    func parse(snippet utf8:[UInt8]) -> (overview:String, slices:[Snippet.Slice])
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

        let rendered:[Snippet.Slice] = slices.map
        {
            (slice:SnippetParser.Slice) in

            let bytecode:Markdown.Bytecode = .init
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

            return .init(id: slice.id, bytecode: bytecode)
        }

        return (text, rendered)
    }
}
