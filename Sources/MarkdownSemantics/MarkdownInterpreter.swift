import MarkdownAST
import UnidocDiagnostics

@frozen public
struct MarkdownInterpreter<Symbolicator> where Symbolicator:DiagnosticSymbolicator<Int32>
{
    public
    var diagnostics:DiagnosticContext<Symbolicator>

    private
    var topicsHeading:Int?
    private
    var topics:[MarkdownDocumentation.Topic]
    private
    var blocks:[MarkdownBlock]

    public
    init(diagnostics:consuming DiagnosticContext<Symbolicator>)
    {
        self.diagnostics = diagnostics

        self.topicsHeading = nil
        self.topics = []
        self.blocks = []
    }
}
extension MarkdownInterpreter
{
    private mutating
    func append(_ block:MarkdownBlock)
    {
        defer
        {
            self.blocks.append(block)
        }

        //  Only h2 headings are interesting, but if we encounter a stray h1, that can
        //  also terminate a topics list.
        guard case (let heading as MarkdownBlock.Heading) = block, heading.level <= 2
        else
        {
            return
        }

        self.interpret()

        if  heading.level == 2,
            heading.elements.count == 1,
            heading.elements[0].text.lowercased() == "topics"
        {
            self.topicsHeading = self.blocks.endIndex
        }
        else
        {
            self.topicsHeading = nil
        }
    }

    private mutating
    func load() -> (article:[MarkdownBlock], topics:[MarkdownDocumentation.Topic])
    {
        defer
        {
            self.topicsHeading = nil
            self.topics = []
            self.blocks = []
        }

        self.interpret()

        return (self.blocks, self.topics)
    }

    private mutating
    func interpret()
    {
        func h3(_ block:MarkdownBlock) -> Bool
        {
            if  case (let heading as MarkdownBlock.Heading) = block, heading.level == 3
            {
                true
            }
            else
            {
                false
            }
        }

        guard
        let start:Int = self.topicsHeading
        else
        {
            return
        }

        var pending:[MarkdownDocumentation.Topic] = []
        var current:Int = self.blocks.index(after: start)

        if  current == self.blocks.endIndex
        {
            return
        }

        /// If the topics list doesn’t begin with an h3 heading, use the topics header
        /// itself as the first topic heading.
        var heading:MarkdownBlock? = h3(self.blocks[current]) ? nil : self.blocks[start]

        while true
        {
            if  let next:Int = self.blocks[self.blocks.index(after: current)...].firstIndex(
                    where: h3(_:))
            {
                guard
                let topic:MarkdownDocumentation.Topic = .init(heading: heading,
                    body: self.blocks[current ..< next])
                else
                {
                    return
                }

                pending.append(topic)
                current = next
                heading = nil
                continue
            }
            else if
                let topic:MarkdownDocumentation.Topic = .init(heading: heading,
                    body: self.blocks[current...])
            {
                self.topics += pending
                self.topics.append(topic)

                self.blocks[start...] = []
            }

            return
        }
    }
}
extension MarkdownInterpreter
{
    public mutating
    func organize(_ blocks:ArraySlice<MarkdownBlock>) -> MarkdownDocumentation
    {
        var parameters:(discussion:[MarkdownBlock], list:[MarkdownBlock.Parameter]) = ([], [])
        var returns:[MarkdownBlock] = []
        var `throws`:[MarkdownBlock] = []

        var metadata:MarkdownDocumentation.Metadata = .init()

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
                        self.append(aside(item.elements))
                    }
                }
                if !items.isEmpty
                {
                    list.elements = items
                    self.append(list)
                }

            case let quote as MarkdownBlock.Quote:
                guard let prefix:MarkdownBlockPrefix = .extract(from: &quote.elements)
                else
                {
                    self.append(quote)
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
                    self.append(aside(quote.elements))
                }

            case let block as MarkdownBlock.Directive:
                switch block.name
                {
                case "Comment":
                    continue

                case "Metadata":
                    metadata.update(with: block.elements)

                case "Snippet":
                    //  Don’t know how to handle these yet, so we just render them
                    //  as code blocks.
                    self.append(block)

                case _:
                    //  Don’t know how to handle these yet, so we just render them
                    //  as code blocks.
                    self.append(block)
                }

            case let block:
                self.append(block)
            }
        }

        var article:[MarkdownBlock]
        let topics:[MarkdownDocumentation.Topic]

        (article, topics) = self.load()

        let overview:MarkdownBlock.Paragraph?
        switch article.first
        {
        case (let paragraph as MarkdownBlock.Paragraph)?:
            overview = paragraph
            article.removeFirst()

        default:
            overview = nil
        }

        return .init(
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
