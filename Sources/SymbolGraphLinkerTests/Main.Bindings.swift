import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Testing_
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
        var ignore:Diagnostics<SSGC.Symbolicator> = .init()

        if  let tests:TestGroup = tests / "Basic"
        {
            let markdown:Markdown.Source = """
            # ``Taylor``

            I think for me, um.
            """
            guard
            let documentation:SSGC.Supplement = tests.expect(value: try? markdown.parse(
                markdownParser: markdownParser,
                snippetsTable: [:],
                diagnostics: &ignore))
            else
            {
                return
            }

            tests.expect(documentation.type.binding?.text.string ==? "Taylor")
        }
        if  let tests:TestGroup = tests / "TrailingComment"
        {
            let markdown:Markdown.Source = """
            # ``Taylor`` <!-- Allison -->

            I think for me, um.
            """
            guard
            let documentation:SSGC.Supplement = tests.expect(value: try? markdown.parse(
                markdownParser: markdownParser,
                snippetsTable: [:],
                diagnostics: &ignore))
            else
            {
                return
            }

            tests.expect(documentation.type.binding?.text.string ==? "Taylor")
        }
        if  let tests:TestGroup = tests / "Tutorial"
        {
            let markdown:Markdown.Source = """
            @Tutorial(time: 0) {
                @Intro(title: "How to meet Taylor") {
                    Learn how to meet Taylor Swift.
                }
            }
            """
            guard
            let documentation:SSGC.Supplement = tests.expect(value: try? markdown.parse(
                markdownParser: markdownParser,
                snippetsTable: [:],
                diagnostics: &ignore))
            else
            {
                return
            }
            guard
            case .tutorial(let headline) = documentation.type
            else
            {
                tests.expect(value: nil as Markdown.Tutorial?)
                return
            }

            tests.expect(headline ==? "How to meet Taylor")
        }
        if  let tests:TestGroup = tests / "TutorialUntitled"
        {
            let markdown:Markdown.Source = """
            @Tutorial(time: 0) {
                @Intro(title: "") {
                    Learn how to meet Taylor Swift.
                }
            }
            """
            tests.expect(nil: try? markdown.parse(
                markdownParser: markdownParser,
                snippetsTable: [:],
                diagnostics: &ignore))
        }
        if  let tests:TestGroup = tests / "SupplementUntitled"
        {
            let markdown:Markdown.Source = """
            ## ``Taylor`` <!-- Allison -->

            I think for me, um.
            """

            tests.expect(nil: try? markdown.parse(
                markdownParser: markdownParser,
                snippetsTable: [:],
                diagnostics: &ignore))
        }
    }
}
