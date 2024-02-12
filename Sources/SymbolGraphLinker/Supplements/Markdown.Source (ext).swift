import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Sources
import SymbolGraphCompiler
import SourceDiagnostics

extension Markdown.Source
{
    convenience
    init(comment:borrowing Compiler.Doccomment, in file:Int32?)
    {
        if  let position:SourcePosition = comment.start,
            let file:Int32
        {
            self.init(origin: .init(position: position, file: file), text: comment.text)
        }
        else
        {
            self.init(origin: nil, text: comment.text)
        }
    }
}
extension Markdown.Source
{
    @_spi(testable) public borrowing
    func parse(_:Markdown.SemanticDocument.Type = Markdown.SemanticDocument.self,
        markdownParser markdown:Markdown.Parser<Markdown.SwiftComment>,
        snippetsTable:[String: Markdown.Snippet],
        diagnostics:inout Diagnostics<StaticSymbolicator>) -> Markdown.SemanticDocument
    {
        let blocks:[Markdown.BlockElement] = markdown.parse(self)
        {
            diagnostics[$1] = .warning($0)
        }

        var interpreter:Markdown.BlockInterpreter<StaticSymbolicator> = .init(
            diagnostics: consume diagnostics)
        defer
        {
            diagnostics = interpreter.diagnostics
        }

        return interpreter.organize(blocks[...], snippets: snippetsTable)
    }

    @_spi(testable) public consuming
    func parse(_:StaticLinker.Supplement.Type = StaticLinker.Supplement.self,
        markdownParser markdown:Markdown.Parser<Markdown.SwiftFlavor>,
        snippetsTable:[String: Markdown.Snippet],
        diagnostics:inout Diagnostics<StaticSymbolicator>) -> StaticLinker.Supplement
    {
        let blocks:[Markdown.BlockElement] = markdown.parse(self)
        {
            diagnostics[$1] = .warning($0)
        }

        var interpreter:Markdown.BlockInterpreter<StaticSymbolicator> = .init(
            diagnostics: consume diagnostics)
        defer
        {
            diagnostics = interpreter.diagnostics
        }

        if  case (let heading as Markdown.BlockHeading)? = blocks.first, heading.level == 1
        {
            let headline:StaticLinker.Supplement.Headline = .init(heading)
            let document:Markdown.SemanticDocument = interpreter.organize(blocks.dropFirst(),
                snippets: snippetsTable)

            return .supplement(headline, document)
        }
        else if
            case (let directive as Markdown.BlockDirective)? = blocks.first
        {
            if  case "Tutorials" = directive.name, blocks.count == 1
            {
                return .tutorials(directive)
            }
            else if
                case "Tutorial" = directive.name, blocks.count == 1
            {
                return .tutorial(directive)
            }
        }

        return .untitled
    }
}
