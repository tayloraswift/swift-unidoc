import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import SourceDiagnostics
import Sources
import SymbolGraphCompiler
import Symbols

extension Markdown.Source
{
    convenience
    init(comment:__shared /* borrowing */ SSGC.DocumentationComment, in file:Int32?)
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
    @_spi(testable) public
    func parse(_:Markdown.SemanticDocument.Type = Markdown.SemanticDocument.self,
        markdownParser markdown:Markdown.Parser<Markdown.SwiftComment>,
        snippetsTable:[String: Markdown.Snippet<Symbol.USR>],
        diagnostics:inout Diagnostics<SSGC.Symbolicator>) -> Markdown.SemanticDocument
    {
        let blocks:[Markdown.BlockElement] = markdown.parse(self)
        {
            diagnostics[$1] = .warning($0)
        }

        var analyzer:Markdown.SemanticAnalyzer<SSGC.Symbolicator> = .init(consume diagnostics,
            snippets: snippetsTable)
        defer
        {
            diagnostics = analyzer.diagnostics
        }

        return analyzer.organize(article: blocks[...])
    }

    @_spi(testable) public
    func parse(_:SSGC.Supplement.Type = SSGC.Supplement.self,
        markdownParser markdown:Markdown.Parser<Markdown.SwiftFlavor>,
        snippetsTable:[String: Markdown.Snippet<Symbol.USR>],
        diagnostics:inout Diagnostics<SSGC.Symbolicator>) throws -> SSGC.Supplement
    {
        let blocks:[Markdown.BlockElement] = markdown.parse(self)
        {
            diagnostics[$1] = .warning($0)
        }

        var analyzer:Markdown.SemanticAnalyzer<SSGC.Symbolicator> = .init(consume diagnostics,
            snippets: snippetsTable)
        defer
        {
            diagnostics = analyzer.diagnostics
        }

        if  case (let tutorial as Markdown.BlockArticle)? = blocks.first
        {
            guard blocks.count == 1
            else
            {
                throw SSGC.SupplementError.extraBlocksInTutorial
            }

            guard
            let headline:String = tutorial.headline, !headline.isEmpty
            else
            {
                throw SSGC.SupplementError.untitledTutorial
            }

            let document:Markdown.SemanticDocument = analyzer.organize(tutorial: tutorial)

            return .init(type: tutorial is Markdown.TutorialIndex
                    ? .tutorials(headline)
                    : .tutorial(headline),
                body: document)
        }
        else if
            case (let heading as Markdown.BlockHeading)? = blocks.first, heading.level == 1
        {
            let headline:SSGC.Supplement.Headline = .init(heading)
            let document:Markdown.SemanticDocument = analyzer.organize(
                article: blocks.dropFirst())

            return .init(type: headline, body: document)
        }
        else
        {
            throw SSGC.SupplementError.untitled
        }
    }
}
