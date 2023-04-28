import Codelinks
import MarkdownABI
import MarkdownTrees

@frozen public
struct MarkdownDocumentation
{
    public
    var parameters:Parameters?
    public
    var returns:Returns?
    public
    var `throws`:Throws?
    public
    var article:[MarkdownTree.Block]

    public
    init(parameters:Parameters?, returns:Returns?, throws:Throws?, article:[MarkdownTree.Block])
    {
        self.parameters = parameters
        self.returns = returns
        self.throws = `throws`
        self.article = article
    }
}
extension MarkdownDocumentation:MarkdownModel
{
    public
    func visit(_ yield:(MarkdownTree.Block) throws -> ()) rethrows
    {
        let discussion:ArraySlice<MarkdownTree.Block>

        if case (let paragraph as MarkdownTree.Paragraph)? = self.article.first
        {
            try yield(paragraph)

            discussion = self.article.dropFirst()
        }
        else
        {
            discussion = self.article[...]
        }

        try yield(Fold.init())

        try self.parameters.map(yield)
        try self.returns.map(yield)
        try self.throws.map(yield)

        try discussion.forEach(yield)
    }
    
    public
    init(attaching blocks:[MarkdownTree.Block])
    {
        var parameters:(discussion:[MarkdownTree.Block], list:[Parameter]) = ([], [])
        var returns:[MarkdownTree.Block] = []
        var `throws`:[MarkdownTree.Block] = []
        var article:[MarkdownTree.Block] = []

        for block:MarkdownTree.Block in blocks
        {
            switch block
            {
            case let list as MarkdownTree.UnorderedList:
                var items:[MarkdownTree.BlockItem] = []
                for item:MarkdownTree.BlockItem in list.elements
                {
                    guard let prefix:MarkdownBlockPrefix = .extract(from: &item.elements)
                    else
                    {
                        items.append(item)
                        continue
                    }
                    switch prefix
                    {
                    case .parameter(let parameter):
                        parameters.list.append(.init(elements: item.elements,
                            name: parameter.name))

                    case .keywords(.parameters):
                        for block:MarkdownTree.Block in item.elements
                        {
                            switch block
                            {
                            case let list as MarkdownTree.UnorderedList:
                                for item:MarkdownTree.BlockItem in list.elements
                                {
                                    let parameter:MarkdownParameterNamePrefix? = .extract(
                                        from: &item.elements)
                                    parameters.list.append(.init(elements: item.elements,
                                        name: parameter?.name ?? "_"))
                                }
                            
                            case let block:
                                parameters.discussion.append(block)
                            }
                        }

                    case .keywords(.returns):
                        returns += item.elements
                    
                    case .keywords(.throws):
                        `throws` += item.elements

                    case .keywords(let aside):
                        article.append(aside(item.elements))
                    }
                }
                if !items.isEmpty
                {
                    list.elements = items
                    article.append(list)
                }
            
            case let quote as MarkdownTree.BlockQuote:
                guard let prefix:MarkdownBlockPrefix = .extract(from: &quote.elements)
                else
                {
                    article.append(quote)
                    continue
                }
                switch prefix
                {
                case .parameter(let parameter):
                    parameters.list.append(.init(elements: quote.elements,
                        name: parameter.name))

                case .keywords(.parameters):
                    parameters.discussion += quote.elements

                case .keywords(.returns):
                    returns += quote.elements
                
                case .keywords(.throws):
                    `throws` += quote.elements

                case .keywords(let aside):
                    article.append(aside(quote.elements))
                }
            
            case let block:
                article.append(block)
            }
        }
    
        self.init(
            parameters: parameters.discussion.isEmpty && parameters.list.isEmpty ?
                nil : .init(parameters.discussion, list: parameters.list),
            returns: returns.isEmpty ? nil : .init(returns),
            throws: `throws`.isEmpty ? nil : .init(`throws`),
            article: article)
    }
}
