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
extension Markdown.BlockInterpreter
{
    /// We currently always eagarly inline snippet slices, which simplifies the rendering model.
    ///
    /// As long as people are not reusing the same slices in multiple places, this has no
    /// performance drawbacks. No one should be doing that (extensively) anyways, because that
    /// would result in documentation that is hard to browse.
    private mutating
    func inline(_ snippet:Markdown.BlockDirective, from snippets:[String: Markdown.Snippet])
    {
        var slice:String? = nil
        var name:String? = nil

        for (argument, value):(String, String) in snippet.arguments
        {
            switch argument
            {
            case "slice":
                slice = value

            //  This is a Unidoc extension, and is not actually part of SE-0356. But SE-0356 is
            //  really poorly written and the `path:` syntax is just awful.
            case "id":
                name = value

            case "path":
                //  We are going to ignore the first path component, which is the package name,
                //  for several reasons.
                //
                //  1.  It serves no purpose to qualify a snippet path with the package name,
                //      other than to accommodate a flawed implementation of Swift DocC.
                //
                //  2.  Package names are extrinsic to the documentation, and would need to be
                //      kept up-to-date with the package name in the `Package.swift`.
                //
                //  3.  Package names can contain URL-unfriendly characters, which would cause
                //      all of their snippets to become unusable. Therefore, DocC `path:`
                //      syntax imposes an additional limitation on package names that is not
                //      legitimized anywhere else.
                guard
                let i:String.Index = value.firstIndex(of: "/"),
                let j:String.Index = value.lastIndex(of: "/")
                else
                {
                    //  TODO: emit diagnostic.
                    continue
                }

                //  OK for the path to contain additional intermediate path components, which
                //  are just as irrelevant as the package name, because snippet names are
                //  unique within a package.
                guard
                case "Snippets" = value[value.index(after: i)...].prefix(while: { $0 != "/" })
                else
                {
                    //  TODO: emit diagnostic.
                    continue
                }

                name = String.init(value[value.index(after: j)...])

            default:
                //  TODO: emit diagnostic.
                print("Unknown @Snippet argument: \(argument)")
                continue
            }
        }

        guard
        let name:String
        else
        {
            //  TODO: emit diagnostic.
            print("Missing @Snippet name")
            return
        }
        guard
        let snippet:Markdown.Snippet = snippets[name]
        else
        {
            //  TODO: emit diagnostic.
            print("Unknown @Snippet name: '\(name)'")
            print("Available snippets: \(snippets.keys.sorted())")
            return
        }

        if  let slice:String
        {
            if  let slice:Markdown.SnippetSlice = snippet.slices[slice]
            {
                self.blocks.append(Markdown.BlockCodeLiteral.init(bytecode: slice.code))
            }
            else
            {
                //  TODO: emit diagnostic.
                print("Unknown @Snippet slice: '\(slice)'")
            }
        }
        else
        {
            //  Snippet captions cannot contain topics, so we can just add them directly to
            //  the ``blocks`` list.
            self.blocks += snippet.caption

            for slice:Markdown.SnippetSlice in snippet.slices.values
            {
                self.blocks.append(Markdown.BlockCodeLiteral.init(bytecode: slice.code))
            }
        }
    }

    private mutating
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

            case let block as Markdown.BlockDirective:
                switch block.name
                {
                case "Comment":
                    continue

                case "Metadata":
                    metadata.update(with: block.elements)

                case "Snippet":
                    self.inline(block, from: snippets)

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
