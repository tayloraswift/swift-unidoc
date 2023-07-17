import Markdown
import MarkdownABI
import MarkdownTrees

@frozen public
struct SwiftFlavoredMarkdownParser
{
    private
    let plugins:[String: any MarkdownCodeLanguageType]
    private
    let `default`:(any MarkdownCodeLanguageType)?

    private
    init(
        plugins:[String: any MarkdownCodeLanguageType],
        default:(any MarkdownCodeLanguageType)? = nil)
    {
        self.plugins = plugins
        self.default = `default`
    }
}
extension SwiftFlavoredMarkdownParser
{
    public
    init(
        plugins:[any MarkdownCodeLanguageType] = [],
        default:(any MarkdownCodeLanguageType)? = nil)
    {
        self.init(plugins: plugins.reduce(into: [:]) { $0[$1.name] = $1 }, default: `default`)
    }
}
extension SwiftFlavoredMarkdownParser:MarkdownParser
{
    public
    func parse(_ string:String, from id:Int) -> [MarkdownBlock]
    {
        let document:Document = .init(parsing: string, options:
        [
            .parseBlockDirectives,
            .parseSymbolLinks,
        ])
        return document.blockChildren.map { self.block(from: $0, in: id) }
    }
}
extension SwiftFlavoredMarkdownParser
{
    private
    func block(from markup:any BlockMarkup, in id:Int) -> MarkdownBlock
    {
        switch markup
        {
        case let block as Markdown.BlockQuote:
            return MarkdownBlock.Quote.init(block.blockChildren.map
                {
                    self.block(from: $0, in: id)
                })

        case let block as Markdown.BlockDirective:
            return MarkdownBlock.Directive.init(name: block.name,
                arguments: block.argumentText.parseNameValueArguments().map
                {
                    ($0.name, $0.value)
                },
                elements: block.blockChildren.map
                {
                    self.block(from: $0, in: id)
                })

        case let block as Markdown.CodeBlock:
            if  let language:String = block.language
            {
                return (self.plugins[language] ?? .unsupported(language)).attach(to: block.code)
            }
            else if
                let plugin:any MarkdownCodeLanguageType = self.default
            {
                return plugin.attach(to: block.code)
            }
            else
            {
                return MarkdownBlock.Code<MarkdownCodeLanguage.PlainText>.init(text: block.code)
            }

        case let block as Markdown.Heading:
            return MarkdownBlock.Heading.init(level: block.level,
                elements: block.inlineChildren.map
                {
                    MarkdownInline.Block.init(from: $0, in: id)
                })

        case let block as Markdown.HTMLBlock:
            return MarkdownBlock.HTML.init(text: block.rawHTML)

        case let block as Markdown.Paragraph:
            return MarkdownBlock.Paragraph.init(block.inlineChildren.map
                {
                    MarkdownInline.Block.init(from: $0, in: id)
                })

        case let table as Markdown.Table:
            return MarkdownTable.init(columns: table.columnAlignments.map
                {
                    switch $0
                    {
                    case nil:       return nil
                    case .left?:    return .left
                    case .center?:  return .center
                    case .right?:   return .right
                    }
                },
                head: table.head.cells.map
                {
                    .init($0.inlineChildren.map
                    {
                        MarkdownInline.Block.init(from: $0, in: id)
                    })
                },
                body: table.body.rows.map
                {
                    $0.cells.map
                    {
                        .init($0.inlineChildren.map
                        {
                            MarkdownInline.Block.init(from: $0, in: id)
                        })
                    }
                })

        case let block as Markdown.ListItem:
            return self.item(from: block, in: id)

        case let block as Markdown.OrderedList:
            return MarkdownBlock.OrderedList.init(block.listItems.map
                {
                    self.item(from: $0, in: id)
                })

        case let block as Markdown.UnorderedList:
            return MarkdownBlock.UnorderedList.init(block.listItems.map
                {
                    self.item(from: $0, in: id)
                })

        case is Markdown.ThematicBreak:
            return MarkdownBlock.ThematicBreak.init()

        case is Markdown.CustomBlock:
            return MarkdownBlock.init()

        case let unsupported:
            return MarkdownBlock.Code<MarkdownCodeLanguage.PlainText>.init(
                text: "<unsupported markdown node '\(type(of: unsupported))' >")
        }
    }

    private
    func item(from markup:ListItem, in id:Int) -> MarkdownBlock.Item
    {
        .init(
            checkbox: markup.checkbox.flatMap { $0 == .checked ? .checked : nil },
            elements: markup.blockChildren.map { self.block(from: $0, in: id) })
    }
}
