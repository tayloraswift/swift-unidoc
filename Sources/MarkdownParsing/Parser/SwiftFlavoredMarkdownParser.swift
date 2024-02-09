import MarkdownABI
import MarkdownAST

@frozen public
struct SwiftFlavoredMarkdownParser<Flavor> where Flavor:MarkdownFlavor
{
    private
    let plugins:[String: any Markdown.CodeLanguageType]
    private
    let `default`:(any Markdown.CodeLanguageType)?

    private
    init(
        plugins:[String: any Markdown.CodeLanguageType],
        default:(any Markdown.CodeLanguageType)? = nil)
    {
        self.plugins = plugins
        self.default = `default`
    }
}
extension SwiftFlavoredMarkdownParser
{
    public
    init(
        plugins:[any Markdown.CodeLanguageType] = [],
        default:(any Markdown.CodeLanguageType)? = nil)
    {
        self.init(plugins: plugins.reduce(into: [:]) { $0[$1.name] = $1 }, default: `default`)
    }
}
extension SwiftFlavoredMarkdownParser:MarkdownParser
{
    public
    func parse(_ source:borrowing MarkdownSource) -> [Markdown.BlockElement]
    {
        let document:_Document = .init(parsing: source.text, options:
        [
            .parseBlockDirectives,
            .parseSymbolLinks,
        ])

        var blocks:[Markdown.BlockElement] = document.blockChildren.compactMap
        {
            self.block(from: $0, in: source)
        }

        Flavor.transform(blocks: &blocks)

        return blocks
    }
}
extension SwiftFlavoredMarkdownParser
{
    private
    func block(
        from markup:borrowing any _BlockMarkup,
        in source:borrowing MarkdownSource) -> Markdown.BlockElement?
    {
        switch copy markup
        {
        case let block as _BlockQuote:
            return Markdown.BlockQuote.init(block.blockChildren.compactMap
                {
                    self.block(from: $0, in: source)
                })

        case let block as _BlockDirective:
            return Markdown.BlockDirective.init(name: block.name,
                arguments: block.argumentText.parseNameValueArguments().map
                {
                    ($0.name, $0.value)
                },
                elements: block.blockChildren.compactMap
                {
                    self.block(from: $0, in: source)
                })

        case let block as _CodeBlock:
            if  let language:String = block.language
            {
                return (self.plugins[language] ?? .unsupported(language)).attach(to: block.code)
            }
            else if
                let plugin:any Markdown.CodeLanguageType = self.default
            {
                return plugin.attach(to: block.code)
            }
            else
            {
                return Markdown.BlockCode<Markdown.PlainText>.init(text: block.code)
            }

        case let block as _Heading:
            return Markdown.BlockHeading.init(level: block.level,
                elements: block.inlineChildren.map
                {
                    Markdown.InlineElement.init(from: $0, in: source)
                })

        case let block as _HTMLBlock:
            let html:Substring = block.rawHTML.drop(while: \.isWhitespace)
            if  html.starts(with: "<!--")
            {
                //  This is a comment, and should be ignored.
                return nil
            }

            return Markdown.BlockHTML.init(text: block.rawHTML)

        case let block as _Paragraph:
            return Markdown.BlockParagraph.init(block.inlineChildren.map
                {
                    Markdown.InlineElement.init(from: $0, in: source)
                })

        case let table as _Table:
            return Markdown.Table.init(columns: table.columnAlignments.map
                {
                    switch $0
                    {
                    case nil:       nil
                    case .left?:    .left
                    case .center?:  .center
                    case .right?:   .right
                    }
                },
                head: table.head.cells.map
                {
                    .init($0.inlineChildren.map
                    {
                        Markdown.InlineElement.init(from: $0, in: source)
                    })
                },
                body: table.body.rows.map
                {
                    $0.cells.map
                    {
                        .init($0.inlineChildren.map
                        {
                            Markdown.InlineElement.init(from: $0, in: source)
                        })
                    }
                })

        case let block as _ListItem:
            return self.item(from: block, in: source)

        case let block as _OrderedList:
            return Markdown.BlockListOrdered.init(block.listItems.map
                {
                    self.item(from: $0, in: source)
                })

        case let block as _UnorderedList:
            return Markdown.BlockListUnordered.init(block.listItems.map
                {
                    self.item(from: $0, in: source)
                })

        case is _ThematicBreak:
            return Markdown.BlockRule.init()

        case is _CustomBlock:
            return Markdown.BlockElement.init()

        case let unsupported:
            return Markdown.BlockCode<Markdown.PlainText>.init(
                text: "<unsupported markdown node '\(type(of: unsupported))' >")
        }
    }

    private
    func item(
        from markup:/* borrowing */ _ListItem,
        in source:borrowing MarkdownSource) -> Markdown.BlockItem
    {
        .init(
            checkbox: markup.checkbox.flatMap { $0 == .checked ? .checked : nil },
            elements: markup.blockChildren.compactMap
            {
                self.block(from: $0, in: source)
            })
    }
}
