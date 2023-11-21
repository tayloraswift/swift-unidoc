import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Testing
import UnidocDiagnostics

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
        let parser:SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdown> = .init()
        var ignore:DiagnosticContext<StaticSymbolicator> = .init()

        if  let tests:TestGroup = tests / "Basic"
        {
            let markdown:MarkdownSource = """
            # ``Taylor``

            I think for me, um.
            """
            let documentation:StaticLinker.Supplement = markdown.parse(using: parser,
                with: &ignore)

            tests.expect(documentation.headline?.binding?.text ==? "Taylor")
        }
        if  let tests:TestGroup = tests / "TrailingComment"
        {
            let markdown:MarkdownSource = """
            # ``Taylor`` <!-- Allison -->

            I think for me, um.
            """
            let documentation:StaticLinker.Supplement = markdown.parse(using: parser,
                with: &ignore)

            tests.expect(documentation.headline?.binding?.text ==? "Taylor")
        }
    }
}