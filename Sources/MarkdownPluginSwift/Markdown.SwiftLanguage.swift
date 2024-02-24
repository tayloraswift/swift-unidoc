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
    func parse(snippet utf8:[UInt8]) -> (caption:String, slices:[Markdown.SnippetSlice])
    {
        //  It is safe to escape the pointer to ``Parser.parse(source:maximumNestingLevel:)``,
        //  see: https://swiftinit.org/docs/swift-syntax/swiftparser/parser.init(_:maximumnestinglevel:parsetransition:arena:)
        let parsed:SourceFileSyntax = utf8.withUnsafeBufferPointer
        {
            Parser.parse(source: $0)
        }

        var start:AbsolutePosition = parsed.position
        var caption:String = ""
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

            caption += line[i...].drop(while: \.isWhitespace)
            caption.append("\n")
        }

        var parser:SnippetParser = .init(sourcemap: .init(fileName: "", tree: parsed),
            start: start)
        for token:TokenSyntax in parsed.tokens(viewMode: .sourceAccurate)
        {
            parser.visit(token: token)
        }

        let slices:[SnippetParser.Slice] = parser.finish(at: parsed.endPosition, in: utf8)
        var cursor:SyntaxClassificationCursor = .init(parsed.classifications)

        let rendered:[Markdown.SnippetSlice] = slices.map
        {
            (slice:SnippetParser.Slice) in

            let bytecode:Markdown.Bytecode = .init
            {
                (output:inout Markdown.BinaryEncoder) in

                for var range:Range<Int> in slice.ranges
                {
                    cursor.step(through: &range)
                    {
                        output[highlight: $1] = utf8[$0]
                    }
                }
            }

            return .init(id: slice.id, line: slice.line, code: bytecode)
        }

        return (caption, rendered)
    }

    public
    func parse(code utf8:[UInt8], diff:[(Range<Int>, Markdown.DiffType?)]) -> Markdown.Bytecode
    {
        .init
        {
            (output:inout Markdown.BinaryEncoder) in

            let parsed:SourceFileSyntax = utf8.withUnsafeBufferPointer
            {
                Parser.parse(source: $0)
            }

            var cursor:SyntaxClassificationCursor = .init(parsed.classifications)

            for case (var range, let type) in diff
            {
                if  let type:Markdown.DiffType
                {
                    output[.diff(type)]
                    {
                        output in
                        cursor.step(through: &range)
                        {
                            output[highlight: $1] = utf8[$0]
                        }
                    }
                }
                else
                {
                    cursor.step(through: &range)
                    {
                        output[highlight: $1] = utf8[$0]
                    }
                }
            }
        }
    }
}
