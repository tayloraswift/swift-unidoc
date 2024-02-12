import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Testing
import SourceDiagnostics

@_spi(testable)
import SymbolGraphLinker

extension Main
{
    struct Bindings
    {
    }
}
extension Main.Bindings:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let markdownParser:Markdown.Parser<Markdown.SwiftFlavor> = .init()
        var ignore:Diagnostics<StaticSymbolicator> = .init()

        if  let tests:TestGroup = tests / "Basic"
        {
            let markdown:Markdown.Source = """
            # ``Taylor``

            I think for me, um.
            """
            let documentation:StaticLinker.Supplement = markdown.parse(
                markdownParser: markdownParser,
                snippetsTable: [:],
                diagnostics: &ignore)

            tests.expect(documentation.headline?.binding?.text ==? "Taylor")
        }
        if  let tests:TestGroup = tests / "TrailingComment"
        {
            let markdown:Markdown.Source = """
            # ``Taylor`` <!-- Allison -->

            I think for me, um.
            """
            let documentation:StaticLinker.Supplement = markdown.parse(
                markdownParser: markdownParser,
                snippetsTable: [:],
                diagnostics: &ignore)

            tests.expect(documentation.headline?.binding?.text ==? "Taylor")
        }
    }
}
