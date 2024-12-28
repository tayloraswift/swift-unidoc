import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import SourceDiagnostics
import Testing

@_spi(testable)
import SymbolGraphLinker

@Suite
struct Bindings
{
    private
    let markdownParser:Markdown.Parser<Markdown.SwiftFlavor>
    private
    var ignore:Diagnostics<SSGC.Symbolicator>

    init()
    {
        self.markdownParser = .init()
        self.ignore = .init()
    }

    @Test mutating
    func Basic() throws
    {
        let markdown:Markdown.Source = """
        # ``Taylor``

        I think for me, um.
        """

        let documentation:SSGC.Supplement = try markdown.parse(
            markdownParser: self.markdownParser,
            snippetsTable: [:],
            diagnostics: &self.ignore)

        #expect(documentation.type.binding?.text.string == "Taylor")
    }
    @Test mutating
    func TrailingComment() throws
    {
        let markdown:Markdown.Source = """
        # ``Taylor`` <!-- Allison -->

        I think for me, um.
        """

        let documentation:SSGC.Supplement = try markdown.parse(
            markdownParser: self.markdownParser,
            snippetsTable: [:],
            diagnostics: &self.ignore)

        #expect(documentation.type.binding?.text.string == "Taylor")
    }
    @Test mutating
    func Tutorial() throws
    {
        let markdown:Markdown.Source = """
        @Tutorial(time: 0) {
            @Intro(title: "How to meet Taylor") {
                Learn how to meet Taylor Swift.
            }
        }
        """
        let documentation:SSGC.Supplement = try markdown.parse(
            markdownParser: self.markdownParser,
            snippetsTable: [:],
            diagnostics: &self.ignore)

        guard
        case .tutorial(let headline) = documentation.type
        else
        {
            Issue.record()
            return
        }

        #expect(headline == "How to meet Taylor")
    }
    @Test mutating
    func TutorialUntitled() throws
    {
        let markdown:Markdown.Source = """
        @Tutorial(time: 0) {
            @Intro(title: "") {
                Learn how to meet Taylor Swift.
            }
        }
        """

        #expect(throws: (any Error).self)
        {
            try markdown.parse(
                markdownParser: self.markdownParser,
                snippetsTable: [:],
                diagnostics: &self.ignore)
        }
    }
    @Test mutating
    func SupplementUntitled() throws
    {
        let markdown:Markdown.Source = """
        ## ``Taylor`` <!-- Allison -->

        I think for me, um.
        """

        #expect(throws: (any Error).self)
        {
            try markdown.parse(
                markdownParser: self.markdownParser,
                snippetsTable: [:],
                diagnostics: &self.ignore)
        }
    }
}
