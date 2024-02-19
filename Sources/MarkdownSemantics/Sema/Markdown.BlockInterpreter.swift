import MarkdownAST
import MarkdownLinking
import SourceDiagnostics

extension Markdown
{
    @frozen public
    struct BlockInterpreter<Symbolicator> where Symbolicator:DiagnosticSymbolicator<Int32>
    {
        public
        var diagnostics:Diagnostics<Symbolicator>

        private
        var topicsHeading:Int?
        private
        var topics:[Markdown.SemanticTopic]
        private
        var blocks:[Markdown.BlockElement]

        public
        init(diagnostics:consuming Diagnostics<Symbolicator>)
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
    private mutating
    func rewrite(children:inout [Markdown.BlockElement],
        inlining snippets:[String: Markdown.Snippet])
    {
        var blocks:[Markdown.BlockElement] = []
            blocks.reserveCapacity(children.count)

        for block:Markdown.BlockElement in consume children
        {
            guard
            case let block as Markdown.BlockCodeFragment = block
            else
            {
                Markdown.SwiftFlavor.rewrite(child: block, into: &blocks)
                continue
            }
            do
            {
                try block.inline(snippets: snippets)
                {
                    //  The snippet inliner might have yielded something that looks like a
                    //  magical block, so we still need to rewrite it.
                    Markdown.SwiftFlavor.rewrite(child: $0, into: &blocks)
                }
            }
            catch let error
            {
                self.diagnostics[block.source] = .error(error)
            }
        }

        children = blocks
    }
}
extension Markdown.BlockInterpreter
{
    public mutating
    func organize(tutorial:Markdown.BlockArticle,
        snippets:[String: Markdown.Snippet]) -> Markdown.SemanticDocument
    {
        tutorial.rewrite
        {
            self.rewrite(children: &$0, inlining: snippets)
        }

        guard
        let intro:Markdown.BlockArticle.Intro = tutorial.overview
        else
        {
            return .tutorial(overview: nil, sections: tutorial.sections)
        }
        guard
        case let paragraph as Markdown.BlockParagraph = intro.elements.first
        else
        {
            return .tutorial(overview: nil, sections: [intro] + tutorial.sections)
        }

        let i:Int = intro.elements.index(after: intro.elements.startIndex)
        if  i < intro.elements.endIndex
        {
            /// This is a weird tutorial, one that contains multiple introductory paragraphs.
            /// We will treat the first paragraph as the overview, and then repack the rest
            /// of the elements into a synthetic body section.
            let section:Markdown.BlockArticle.Section = .init()
                section.elements = [_].init(intro.elements[i...])
            return .tutorial(overview: paragraph, sections: [section] + tutorial.sections)
        }
        else
        {
            return .tutorial(overview: paragraph, sections: tutorial.sections)
        }
    }

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
            block.rewrite
            {
                self.rewrite(children: &$0, inlining: snippets)
            }

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

            case let block as Markdown.BlockMetadata:
                metadata.update(docc: block)

            case let block as Markdown.BlockCodeFragment:
                //  We still need to do this here, as it is a top-level block and therefore
                //  not subject to the automatic rewrite.
                do
                {
                    try block.inline(snippets: snippets)
                    {
                        self.append($0)
                    }
                }
                catch let error
                {
                    self.diagnostics[block.source] = .error(error)
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
