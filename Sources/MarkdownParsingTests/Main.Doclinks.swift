import MarkdownAST
import MarkdownParsing
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
        let parser:SwiftFlavoredMarkdownParser<SwiftFlavoredMarkdown> = .init()
        for (name, source, expected):(String, MarkdownSource, String) in
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
            let tree:MarkdownTree = .init { parser.parse(source) }
            if  let tests:TestGroup = tests / name,
                let paragraph:MarkdownBlock.Paragraph = tests.expect(
                    value: tree.blocks.first as? MarkdownBlock.Paragraph),
                let autolink:MarkdownInline.Autolink = tests.expect(
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
