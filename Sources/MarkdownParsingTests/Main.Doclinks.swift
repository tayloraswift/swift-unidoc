import MarkdownAST
import MarkdownParsing
import MarkdownSemantics
import Testing

extension Main
{
    struct Doclinks
    {
    }
}
extension Main.Doclinks:TestBattery
{
    static
    func run(tests:TestGroup)
    {
        let parser:Markdown.Parser<Markdown.SwiftFlavor> = .init()
        for (name, source, expected):(String, Markdown.Source, String) in
        [
            (
                "Basic",
                "<doc:GettingStarted>",
                "GettingStarted"
            ),
            (
                "PercentEncoded",
                "<doc:Getting%20Started>",
                "Getting%20Started"
            ),
            (
                "Qualified",
                "<doc:BarbieCore/Getting%20Started>",
                "BarbieCore/Getting%20Started"
            ),
        ]
        {
            let tree:Markdown.Tree = .init { parser.parse(source) }
            if  let tests:TestGroup = tests / name,
                let paragraph:Markdown.BlockParagraph = tests.expect(
                    value: tree.blocks.first as? Markdown.BlockParagraph),
                let autolink:Markdown.InlineAutolink = tests.expect(
                    value:
                    {
                        switch $0
                        {
                        case .autolink(let autolink):   autolink
                        case _:                         nil
                        }
                    } (paragraph.elements.first))
            {
                tests.expect(false: autolink.code)
                tests.expect(autolink.text ==? expected)
            }
        }
    }
}
