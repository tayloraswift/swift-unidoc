import MarkdownAST
import SourceDiagnostics

extension Markdown
{
    @frozen public
    struct SemanticAnalyzer<Symbolicator> where Symbolicator:DiagnosticSymbolicator<Int32>
    {
        public private(set)
        var diagnostics:Diagnostics<Symbolicator>

        private
        let snippets:[String: Snippet]

        private
        var metadata:SemanticMetadata

        private
        var parameterList:[BlockParameter]
        private
        var parameters:[BlockElement]
        private
        var returns:[BlockElement]
        private
        var `throws`:[BlockElement]

        public
        init(_ diagnostics:consuming Diagnostics<Symbolicator>, snippets:[String: Snippet])
        {
            self.diagnostics = diagnostics
            self.snippets = snippets

            self.metadata = .init()

            self.parameterList = []
            self.parameters = []
            self.returns = []
            self.throws = []
        }
    }
}
extension Markdown.SemanticAnalyzer
{
    public mutating
    func organize(
        tutorial:borrowing Markdown.BlockArticle) -> Markdown.SemanticDocument
    {
        tutorial.rewrite { self.rewrite(blocks: &$0) }

        guard
        let intro:Markdown.BlockArticle.Intro = tutorial.overview
        else
        {
            return self.load(overview: nil, details: tutorial.sections)
        }
        guard
        case let paragraph as Markdown.BlockParagraph = intro.elements.first
        else
        {
            return self.load(overview: nil, details: [intro] + tutorial.sections)
        }

        let i:Int = intro.elements.index(after: intro.elements.startIndex)
        if  i < intro.elements.endIndex
        {
            /// This is a weird tutorial, one that contains multiple introductory paragraphs.
            /// We will treat the first paragraph as the overview, and then repack the rest
            /// of the elements into a synthetic body section.
            let section:Markdown.BlockArticle.Section = .init()
                section.elements = [_].init(intro.elements[i...])
            return self.load(overview: paragraph, details: [section] + tutorial.sections)
        }
        else
        {
            return self.load(overview: paragraph, details: tutorial.sections)
        }
    }

    /// Rewrites the given block elements recursively.
    public mutating
    func organize(
        article:consuming ArraySlice<Markdown.BlockElement>) -> Markdown.SemanticDocument
    {
        //  Rewrite the top-level markup.
        var article:[Markdown.BlockElement] = self.rewrite(blocks: article)
        //  Rewrite the nested markup.
        for block:Markdown.BlockElement in article
        {
            block.rewrite { self.rewrite(blocks: &$0) }
        }

        let overview:Markdown.BlockParagraph?

        if  case (let paragraph as Markdown.BlockParagraph)? = article.first
        {
            overview = paragraph
            article.removeFirst()
        }
        else
        {
            overview = nil
        }

        return self.load(overview: overview, details: article)
    }
}
extension Markdown.SemanticAnalyzer
{
    /// Rewrites the given block elements non-recursively.
    private mutating
    func rewrite(blocks:consuming ArraySlice<Markdown.BlockElement>) -> [Markdown.BlockElement]
    {
        var rewritten:[Markdown.BlockElement] = []
            rewritten.reserveCapacity((copy blocks).count)
        for block:Markdown.BlockElement in blocks
        {
            self.expand(block: block)
            {
                rewritten.append($0)
            }
        }

        return rewritten
    }

    /// Rewrites the given block elements non-recursively.
    private mutating
    func rewrite(blocks:inout [Markdown.BlockElement])
    {
        blocks = self.rewrite(blocks: (consume blocks)[...])
    }

    private mutating
    func expand(block:consuming Markdown.BlockElement,
        into yield:(consuming Markdown.BlockElement) -> ())
    {
        switch block
        {
        case let block as Markdown.BlockCodeFragment:
            do
            {
                try block.inline(snippets: self.snippets)
                {
                    self.remove(block: $0, else: yield)
                }
            }
            catch let error
            {
                self.diagnostics[block.source] = .error(error)
            }

        case let block:
            self.remove(block: block, else: yield)
        }
    }

    private mutating
    func remove(block:consuming Markdown.BlockElement,
        else yield:(consuming Markdown.BlockElement) -> ())
    {
        switch block
        {
        case let list as Markdown.BlockListUnordered:
            var terms:[Markdown.BlockTerm] = []
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
                    self.parameterList.append(.init(elements: item.elements,
                        name: parameter.name))

                case .term(let term):
                    terms.append(.init(elements: item.elements,
                        name: term.name,
                        code: term.style == .code))

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
                                self.parameterList.append(.init(elements: item.elements,
                                    name: parameter?.name ?? "_"))
                            }

                        case let block:
                            self.parameters.append(block)
                        }
                    }

                case .keywords(.returns):
                    self.returns += item.elements

                case .keywords(.throws):
                    self.throws += item.elements

                case .keywords(let aside):
                    yield(aside(item.elements))
                }
            }
            if !terms.isEmpty
            {
                yield(Markdown.BlockTerms.init(terms))
            }
            if !items.isEmpty
            {
                list.elements = items
                yield(list)
            }

        case let quote as Markdown.BlockQuote:
            //  Parsing the prefixes this way is a little less efficient than using
            //  the `Markdown.BlockPrefix` type, but it means we don’t have to repair
            //  markup if we encounter a prefix that is not allowed to appear here.
            if  let parameter:Markdown.ParameterPrefix = .extract(
                    from: &quote.elements)
            {
                self.parameterList.append(.init(elements: quote.elements,
                    name: parameter.name))
            }
            else if
                let keywords:Markdown.KeywordPrefix = .extract(
                    from: &quote.elements)
            {
                switch keywords
                {
                case .parameters:
                    self.parameters += quote.elements

                case .returns:
                    self.returns += quote.elements

                case .throws:
                    self.throws += quote.elements

                case let aside:
                    yield(aside(quote.elements))
                }
            }
            else
            {
                yield(quote)
            }

        case let block as Markdown.BlockMetadata:
            self.metadata.update(docc: block)

        case let block:
            yield(block)
        }
    }
}
extension Markdown.SemanticAnalyzer
{
    private mutating
    func load(
        overview:consuming Markdown.BlockParagraph?,
        details:consuming [Markdown.BlockElement]) -> Markdown.SemanticDocument
    {
        /// Was the last `h2` heading a “Topics” heading?
        var insideTopicsSection:Bool = false
        /// Was the last markdown block a major (`h3` or greater) heading?
        var afterMajorHeading:Bool = false

        var article:[Markdown.BlockElement] = []
            article.reserveCapacity((copy details).count)
        var topics:[Markdown.BlockTopic] = []

        for block:Markdown.BlockElement in details
        {
            switch block
            {
            case let heading as Markdown.BlockHeading:
                switch heading.level
                {
                case 2:
                    afterMajorHeading = true

                    if  heading.elements.count == 1,
                        heading.elements[0].text.lowercased() == "topics"
                    {
                        insideTopicsSection = true
                        continue
                    }
                    else
                    {
                        insideTopicsSection = false
                    }

                case 3:
                    afterMajorHeading = true

                case _:
                    afterMajorHeading = false
                }

                if  insideTopicsSection
                {
                    heading.promote(by: 1)
                }

                article.append(heading)

            case let list as Markdown.BlockListUnordered:
                if  insideTopicsSection || afterMajorHeading,
                    let topic:Markdown.BlockTopic = .init(from: list)
                {
                    article.append(topic)
                    topics.append(topic)
                }
                else
                {
                    article.append(list)
                }

                afterMajorHeading = false

            case let block:
                afterMajorHeading = false
                article.append(block)
            }
        }

        defer
        {
            self.metadata = .init()
            self.parameterList.removeAll(keepingCapacity: true)
            self.parameters.removeAll(keepingCapacity: true)
            self.returns.removeAll(keepingCapacity: true)
            self.throws.removeAll(keepingCapacity: true)
        }

        return .init(
            metadata: self.metadata,
            overview: overview,
            details: .init(
                parameters: self.parameters.isEmpty && self.parameterList.isEmpty ?
                    nil : .init(self.parameters, list: self.parameterList),
                returns: self.returns.isEmpty ? nil : .init(self.returns),
                throws: self.throws.isEmpty ? nil : .init(self.throws),
                article: article),
            topics: topics)
    }
}
