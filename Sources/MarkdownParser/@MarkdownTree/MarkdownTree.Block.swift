import Markdown

extension MarkdownTree.Block
{
    static
    func create(from markup:any BlockMarkup) -> MarkdownTree.Block
    {
        switch markup 
        {
        case let block as BlockQuote:
            return MarkdownTree.BlockQuote.init(block.blockChildren.map(Self.create(from:)))
        
        case let block as BlockDirective:
            return MarkdownTree.BlockDirective.init(name: block.name,
                arguments: block.argumentText.parseNameValueArguments().map
                {
                    ($0.name, $0.value)
                },
                elements: block.blockChildren.map(Self.create(from:)))
        
        case let block as CodeBlock:
            return MarkdownTree.BlockCode.init(language: block.language, text: block.code)
        
        case let block as Heading: 
            return MarkdownTree.Heading.init(level: block.level,
                elements: block.inlineChildren.map(MarkdownTree.InlineBlock.init(from:)))
        
        case let block as HTMLBlock:
            return MarkdownTree.BlockHTML.init(text: block.rawHTML)
        
        case let block as Paragraph:
            return MarkdownTree.Paragraph.init(block.inlineChildren.map(
                MarkdownTree.InlineBlock.init(from:)))
            
        case let table as Table:
            return MarkdownTree.Table.init(columns: table.columnAlignments.map
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
                    .init($0.inlineChildren.map(MarkdownTree.InlineBlock.init(from:)))
                },
                body: table.body.rows.map
                {
                    $0.cells.map
                    {
                        .init($0.inlineChildren.map(MarkdownTree.InlineBlock.init(from:)))
                    }
                })
        
        case let block as ListItem:
            return MarkdownTree.BlockItem.init(from: block)

        case let block as OrderedList:
            return MarkdownTree.OrderedList.init(block.listItems.map(
                MarkdownTree.BlockItem.init(from:)))
        
        case let block as UnorderedList:
            return MarkdownTree.UnorderedList.init(block.listItems.map(
                MarkdownTree.BlockItem.init(from:)))
        
        case is ThematicBreak: 
            return MarkdownTree.ThematicBreak.init()
        
        case is CustomBlock:
            return MarkdownTree.Block.init()
        
        case let unsupported:
            return MarkdownTree.BlockCode.init(
                text: "<unsupported markdown node '\(type(of: unsupported))' >")
        }
    }
}
