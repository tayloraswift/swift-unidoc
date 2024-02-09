import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Sources
import SymbolGraphCompiler
import UnidocDiagnostics

extension MarkdownSource
{
    convenience
    init(comment:borrowing Compiler.Doccomment, in file:Int32?)
    {
        if  let position:SourcePosition = comment.start,
            let file:Int32
        {
            self.init(location: .init(position: position, file: file), text: comment.text)
        }
        else
        {
            self.init(location: nil, text: comment.text)
        }
    }
}
extension MarkdownSource
{
    @_spi(testable) public borrowing
    func parse(_:Markdown.SemanticDocument.Type = Markdown.SemanticDocument.self,
        using parser:borrowing SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdownComment>,
        with diagnostics:inout DiagnosticContext<StaticSymbolicator>) -> Markdown.SemanticDocument
    {
        var interpreter:Markdown.BlockInterpreter<StaticSymbolicator> = .init(
            diagnostics: consume diagnostics)
        defer
        {
            diagnostics = interpreter.diagnostics
        }
        return interpreter.organize(parser.parse(self)[...])
    }

    @_spi(testable) public consuming
    func parse(_:StaticLinker.Supplement.Type = StaticLinker.Supplement.self,
        using parser:borrowing SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdown>,
        with diagnostics:inout DiagnosticContext<StaticSymbolicator>) -> StaticLinker.Supplement
    {
        var interpreter:Markdown.BlockInterpreter<StaticSymbolicator> = .init(
            diagnostics: consume diagnostics)
        defer
        {
            diagnostics = interpreter.diagnostics
        }

        let blocks:[Markdown.BlockElement] = parser.parse(copy self)

        if  case (let heading as Markdown.BlockHeading)? = blocks.first, heading.level == 1
        {
            return .init(headline: .init(heading),
                parsed: interpreter.organize(blocks.dropFirst()),
                source: self)
        }
        else
        {
            return .init(headline: nil,
                parsed: interpreter.organize(blocks[...]),
                source: self)
        }
    }
}
