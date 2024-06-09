import MarkdownABI
import Snippets
import SwiftIDEUtils
import SwiftParser
import SwiftSyntax
import Symbols

extension Markdown
{
    @frozen public
    struct SwiftLanguage
    {
        @usableFromInline
        let index:(any IndexStore)?

        @inlinable
        init(index:(any IndexStore)? = nil)
        {
            self.index = index
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
    func parse(snippet utf8:[UInt8],
        from indexID:String? = nil) ->
    (
        caption:String,
        slices:[Markdown.SnippetSlice<Symbol.USR>]
    )
    {
        let links:[Int: IndexMarker]

        if  let indexID:String,
            let index:any IndexStore = self.index
        {
            links = index.load(for: indexID, utf8: utf8)
        }
        else
        {
            links = [:]
        }

        //  It is safe to escape the pointer to ``Parser.parse(source:maximumNestingLevel:)``,
        //  see: https://swiftinit.org/docs/swift-syntax/swiftparser/parser.init(_:maximumnestinglevel:parsetransition:arena:)
        let parsed:SourceFileSyntax = utf8.withUnsafeBufferPointer
        {
            Parser.parse(source: $0)
        }

        var parser:SnippetParser = .init(sourcemap: .init(fileName: "", tree: parsed),
            start: parsed.position)
        for token:TokenSyntax in parsed.tokens(viewMode: .sourceAccurate)
        {
            parser.visit(token: token)
        }

        let (caption, slices):(String, [SnippetParser.Slice]) = parser.finish(
            at: parsed.endPosition,
            in: utf8)

        var cursor:SyntaxClassificationCursor = .init(parsed.classifications, links: links)

        let rendered:[Markdown.SnippetSlice<Symbol.USR>] = slices.map
        {
            var code:[Markdown.SnippetFragment<Symbol.USR>] = []

            for var range:Range<Int> in $0.ranges
            {
                cursor.step(through: &range)
                {
                    code.append(.init(range: $0, color: $1.color, usr: $1.usr))
                }
            }

            return .init(id: $0.id, line: $0.line, utf8: utf8, code: code)
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
                            output[highlight: $1.color] = utf8[$0]
                        }
                    }
                }
                else
                {
                    cursor.step(through: &range)
                    {
                        output[highlight: $1.color] = utf8[$0]
                    }
                }
            }
        }
    }
}
