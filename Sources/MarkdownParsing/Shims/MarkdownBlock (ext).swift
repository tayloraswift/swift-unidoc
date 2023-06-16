import Markdown
import MarkdownTrees

extension MarkdownBlock
{
    static
    func create(from markup:any BlockMarkup, in id:Int) -> MarkdownBlock
    {
        switch markup
        {
        case let block as Markdown.BlockQuote:
            return MarkdownBlock.Quote.init(block.blockChildren.map
                {
                    Self.create(from: $0, in: id)
                })

        case let block as Markdown.BlockDirective:
            return MarkdownBlock.Directive.init(name: block.name,
                arguments: block.argumentText.parseNameValueArguments().map
                {
                    ($0.name, $0.value)
                },
                elements: block.blockChildren.map
                {
                    Self.create(from: $0, in: id)
                })

        case let block as Markdown.CodeBlock:
            return MarkdownBlock.Code.init(language: block.language, text: block.code)

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
            return MarkdownBlock.Item.init(from: block, in: id)

        case let block as Markdown.OrderedList:
            return MarkdownBlock.OrderedList.init(block.listItems.map
                {
                    MarkdownBlock.Item.init(from: $0, in: id)
                })

        case let block as Markdown.UnorderedList:
            return MarkdownBlock.UnorderedList.init(block.listItems.map
                {
                    MarkdownBlock.Item.init(from: $0, in: id)
                })

        case is Markdown.ThematicBreak:
            return MarkdownBlock.ThematicBreak.init()

        case is Markdown.CustomBlock:
            return MarkdownBlock.init()

        case let unsupported:
            return MarkdownBlock.Code.init(
                text: "<unsupported markdown node '\(type(of: unsupported))' >")
        }
    }
}
