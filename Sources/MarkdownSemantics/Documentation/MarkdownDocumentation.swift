import MarkdownAST

@frozen public
struct MarkdownDocumentation
{
    public
    var metadata:Metadata
    public
    var overview:MarkdownBlock.Paragraph?
    public
    var details:Details
    public
    var topics:[Topic]

    @inlinable public
    init(
        metadata:Metadata,
        overview:MarkdownBlock.Paragraph?,
        details:Details,
        topics:[Topic])
    {
        self.metadata = metadata
        self.overview = overview
        self.details = details
        self.topics = topics
    }
}
extension MarkdownDocumentation:MarkdownModel
{
    public
    init(parser parse:() -> [MarkdownBlock])
    {
        self.init(attaching: parse())
    }
}
extension MarkdownDocumentation
{
    init(attaching blocks:some Sequence<MarkdownBlock>)
    {
        var parameters:(discussion:[MarkdownBlock], list:[MarkdownBlock.Parameter]) = ([], [])
        var returns:[MarkdownBlock] = []
        var `throws`:[MarkdownBlock] = []

        var interpreter:MarkdownInterpreter = .init()
        var metadata:Metadata = .init()

        for block:MarkdownBlock in blocks
        {
            switch block
            {
            case let list as MarkdownBlock.UnorderedList:
                var items:[MarkdownBlock.Item] = []
                for item:MarkdownBlock.Item in list.elements
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
                        for block:MarkdownBlock in item.elements
                        {
                            switch block
                            {
                            case let list as MarkdownBlock.UnorderedList:
                                for item:MarkdownBlock.Item in list.elements
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
                        interpreter.append(aside(item.elements))
                    }
                }
                if !items.isEmpty
                {
                    list.elements = items
                    interpreter.append(list)
                }

            case let quote as MarkdownBlock.Quote:
                guard let prefix:MarkdownBlockPrefix = .extract(from: &quote.elements)
                else
                {
                    interpreter.append(quote)
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
                    interpreter.append(aside(quote.elements))
                }

            case let block as MarkdownBlock.Directive:
                guard block.name == "Metadata"
                else
                {
                    //  Don’t know how to handle these yet, so we just render them
                    //  as code blocks.
                    interpreter.append(block)
                    continue
                }

                metadata.update(with: block.elements)

            case let block:
                interpreter.append(block)
            }
        }

        var article:[MarkdownBlock]
        let topics:[MarkdownDocumentation.Topic]

        (article, topics) = interpreter.load()

        let overview:MarkdownBlock.Paragraph?
        switch article.first
        {
        case (let paragraph as MarkdownBlock.Paragraph)?:
            overview = paragraph
            article.removeFirst()

        default:
            overview = nil
        }

        self.init(
            metadata: metadata,
            overview: overview,
            details: .init(
                parameters: parameters.discussion.isEmpty && parameters.list.isEmpty ?
                    nil : .init(parameters.discussion, list: parameters.list),
                returns: returns.isEmpty ? nil : .init(returns),
                throws: `throws`.isEmpty ? nil : .init(`throws`),
                article: article),
            topics: topics)
    }
}
extension MarkdownDocumentation
{
    /// Merges the given documentation into this documentation.
    ///
    /// If this documentation has no Parameters, Returns, or Throws sections,
    /// then this function adds them from the new documentation, if it has them.
    /// If the new documentation has such sections, but they are already present
    /// in this documentation, then the new documentation’s sections are ignored.
    ///
    /// If the new documentation has an Overview section, then this function adds
    /// it to this documentation Details section as a regular body paragraph, even
    /// if this documentation lacks an Overview section of its own.
    public mutating
    func merge(appending body:MarkdownDocumentation)
    {
        if  let first:MarkdownBlock.Paragraph = body.overview
        {
            self.details.article.append(first)
        }
        if  case nil = self.details.parameters
        {
            self.details.parameters = body.details.parameters
        }
        if  case nil = self.details.returns
        {
            self.details.returns = body.details.returns
        }
        if  case nil = self.details.throws
        {
            self.details.throws = body.details.throws
        }

        self.details.article += body.details.article
        self.topics += body.topics
    }
}
