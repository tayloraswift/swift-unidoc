import MarkdownAST
import UnidocDiagnostics

extension Markdown
{
    @frozen public
    struct BlockInterpreter<Symbolicator> where Symbolicator:DiagnosticSymbolicator<Int32>
    {
        public
        var diagnostics:DiagnosticContext<Symbolicator>

        private
        var topicsHeading:Int?
        private
        var topics:[Markdown.SemanticTopic]
        private
        var blocks:[Markdown.BlockElement]

        public
        init(diagnostics:consuming DiagnosticContext<Symbolicator>)
        {
            self.diagnostics = diagnostics

            self.topicsHeading = nil
            self.topics = []
            self.blocks = []
        }
    }
}
extension Markdown.BlockInterpreter:Markdown.SemanticInterpreter
{
    mutating
    func append(_ block:Markdown.BlockElement)
    {
        defer
        {
            self.blocks.append(block)
        }

        //  Only h2 headings are interesting, but if we encounter a stray h1, that can
        //  also terminate a topics list.
        guard case (let heading as Markdown.BlockHeading) = block, heading.level <= 2
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
}
extension Markdown.BlockInterpreter
{
    private mutating
    func record(error:any Error, in block:Markdown.BlockElement)
    {
        //  TODO: unimplemented
        dump(error)
    }

    private mutating
    func load() -> (article:[Markdown.BlockElement], topics:[Markdown.SemanticTopic])
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
        func h3(_ block:Markdown.BlockElement) -> Bool
        {
            if  case (let heading as Markdown.BlockHeading) = block, heading.level == 3
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

        var pending:[Markdown.SemanticTopic] = []
        var current:Int = self.blocks.index(after: start)

        if  current == self.blocks.endIndex
        {
            return
        }

        /// If the topics list doesn’t begin with an h3 heading, use the topics header
        /// itself as the first topic heading.
        var heading:Markdown.BlockElement? = h3(self.blocks[current]) ? nil : self.blocks[start]

        while true
        {
            if  let next:Int = self.blocks[self.blocks.index(after: current)...].firstIndex(
                    where: h3(_:))
            {
                guard
                let topic:Markdown.SemanticTopic = .init(heading: heading,
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
                let topic:Markdown.SemanticTopic = .init(heading: heading,
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

extension Markdown.BlockInterpreter
{
    public mutating
    func organize(_ blocks:ArraySlice<Markdown.BlockElement>,
        snippets:[String: Markdown.Snippet]) -> Markdown.SemanticDocument
    {
        var parameters:(discussion:[Markdown.BlockElement], list:[Markdown.BlockParameter]) =
        (
            [],
            []
        )
        var returns:[Markdown.BlockElement] = []
        var `throws`:[Markdown.BlockElement] = []

        var metadata:Markdown.SemanticMetadata = .init()

        for block:Markdown.BlockElement in blocks
        {
            switch block
            {
            case let list as Markdown.BlockListUnordered:
                var items:[Markdown.BlockItem] = []
                for item:Markdown.BlockItem in list.elements
                {
                    guard
                    let prefix:Markdown.BlockPrefix = .extract(from: &item.elements)
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
                        for block:Markdown.BlockElement in item.elements
                        {
                            switch block
                            {
                            case let list as Markdown.BlockListUnordered:
                                for item:Markdown.BlockItem in list.elements
                                {
                                    let parameter:Markdown.ParameterNamePrefix? = .extract(
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

            case let quote as Markdown.BlockQuote:
                guard
                let prefix:Markdown.BlockPrefix = .extract(from: &quote.elements)
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

            case let block as Markdown.BlockCodeReference:
                do
                {
                    try block.inline(into: &self, from: snippets)
                }
                catch let error
                {
                    self.record(error: error, in: block)
                }

            case let block as Markdown.BlockDirective:
                switch block.name
                {
                case "Metadata":
                    metadata.update(with: block.elements)

                case _:
                    //  Don’t know how to handle these yet, so we just render them
                    //  as code blocks.
                    self.append(block)
                }

            case let block:
                self.append(block)
            }
        }

        var article:[Markdown.BlockElement]
        let topics:[Markdown.SemanticTopic]

        (article, topics) = self.load()

        let overview:Markdown.BlockParagraph?
        switch article.first
        {
        case (let paragraph as Markdown.BlockParagraph)?:
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
