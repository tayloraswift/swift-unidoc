import MarkdownABI
import MarkdownAST
import Sources

extension Markdown
{
    @frozen public
    struct Parser<Flavor> where Flavor:Markdown.ParsingFlavor
    {
        private
        let plugins:[String: any Markdown.CodeLanguageType]
        private
        let `default`:(any Markdown.CodeLanguageType)?

        private
        var errors:[(any Error, at:SourceReference<Source>)] = []

        private
        init(
            plugins:[String: any Markdown.CodeLanguageType],
            default:(any Markdown.CodeLanguageType)? = nil)
        {
            self.plugins = plugins
            self.default = `default`

            self.errors = []
        }
    }
}
extension Markdown.Parser
{
    public
    init(
        plugins:[any Markdown.CodeLanguageType] = [],
        default:(any Markdown.CodeLanguageType)? = nil)
    {
        self.init(plugins: plugins.reduce(into: [:]) { $0[$1.name] = $1 }, default: `default`)
    }
}
extension Markdown.Parser:Markdown.ParsingEngine
{
    public
    func parse(_ source:borrowing Markdown.Source,
        onError:(any Error, SourceReference<Markdown.Source>) -> ()) -> [Markdown.BlockElement]
    {
        let document:_Document = .init(parsing: source.text, options:
        [
            .parseBlockDirectives,
            .parseSymbolLinks,
        ])

        var blocks:[Markdown.BlockElement] = []
            blocks.reserveCapacity(document.childCount)

        /// There really ought to be a more elegant way to do this...
        var _copy:Self = self
        for child:any _BlockMarkup in document.blockChildren
        {
            guard
            let block:Markdown.BlockElement = _copy.parse(block: child, from: source)
            else
            {
                continue
            }

            Flavor.process(toplevel: block)
            blocks.append(block)
        }

        for (error, subject):(any Error, SourceReference<Markdown.Source>) in _copy.errors
        {
            onError(error, subject)
        }

        return blocks
    }
}
extension Markdown.Parser
{
    private mutating
    func parse(block markup:/* borrowing */ any _BlockMarkup,
        from source:Markdown.Source) -> Markdown.BlockElement?
    {
        switch /* copy */ markup
        {
        case let block as _BlockQuote:
            return Markdown.BlockQuote.init(block.blockChildren.compactMap
                {
                    self.parse(block: $0, from: source)
                })

        case let block as _BlockDirective:
            guard
            let directive:any Markdown.BlockDirectiveType = Flavor[instantiating: block.name]
            else
            {
                return nil
            }

            directive.source = .init(from: block.nameRange, in: source)

            for argument:_DirectiveArgument in block.argumentText.parseNameValueArguments()
            {
                do
                {
                    try directive.configure(
                        option: argument.name,
                        value: .init(
                            source: .init(from: argument.valueRange, in: source),
                            string: argument.value))
                }
                catch let error
                {
                    self.errors.append((error, at: .init(from: argument.nameRange, in: source)))
                }
            }

            for child:any _BlockMarkup in block.blockChildren
            {
                guard
                let block:Markdown.BlockElement = self.parse(block: child, from: source)
                else
                {
                    continue
                }

                do
                {
                    try directive.append(block)
                }
                catch let error
                {
                    self.errors.append((error, at: .init(from: child.range, in: source)))
                }
            }

            return directive

        case let block as _CodeBlock:
            if  let language:String = block.language
            {
                return (self.plugins[language] ?? .unsupported(language)).attach(to: block.code)
            }
            else if
                let plugin:any Markdown.CodeLanguageType = self.default
            {
                return plugin.attach(to: block.code)
            }
            else
            {
                return Markdown.BlockCode<Markdown.PlainText>.init(text: block.code)
            }

        case let block as _Heading:
            return Markdown.BlockHeading.init(
                source: .init(from: block.range, in: source),
                level: block.level,
                elements: block.inlineChildren.map
                {
                    Markdown.InlineElement.init(from: $0, in: source)
                })

        case let block as _HTMLBlock:
            let html:Substring = block.rawHTML.drop(while: \.isWhitespace)
            if  html.starts(with: "<!--")
            {
                //  This is a comment, and should be ignored.
                return nil
            }

            return Markdown.BlockHTML.init(text: block.rawHTML)

        case let block as _Paragraph:
            return Markdown.BlockParagraph.init(block.inlineChildren.map
                {
                    Markdown.InlineElement.init(from: $0, in: source)
                })

        case let table as _Table:
            return Markdown.Table.init(columns: table.columnAlignments.map
                {
                    switch $0
                    {
                    case nil:       nil
                    case .left?:    .left
                    case .center?:  .center
                    case .right?:   .right
                    }
                },
                head: table.head.cells.map
                {
                    .init($0.inlineChildren.map
                    {
                        Markdown.InlineElement.init(from: $0, in: source)
                    })
                },
                body: table.body.rows.map
                {
                    $0.cells.map
                    {
                        .init($0.inlineChildren.map
                        {
                            Markdown.InlineElement.init(from: $0, in: source)
                        })
                    }
                })

        case let block as _ListItem:
            return self.parse(item: block, from: source)

        case let block as _OrderedList:
            return Markdown.BlockListOrdered.init(block.listItems.map
                {
                    self.parse(item: $0, from: source)
                })

        case let block as _UnorderedList:
            return Markdown.BlockListUnordered.init(block.listItems.map
                {
                    self.parse(item: $0, from: source)
                })

        case is _ThematicBreak:
            return Markdown.BlockRule.init()

        case is _CustomBlock:
            return Markdown.BlockElement.init()

        case let unsupported:
            return Markdown.BlockCode<Markdown.PlainText>.init(
                text: "<unsupported markdown node '\(type(of: unsupported))' >")
        }
    }

    private mutating
    func parse(
        item markup:/* borrowing */ _ListItem,
        from source:borrowing Markdown.Source) -> Markdown.BlockItem
    {
        .init(
            checkbox: markup.checkbox.flatMap { $0 == .checked ? .checked : nil },
            elements: markup.blockChildren.compactMap
            {
                self.parse(block: $0, from: source)
            })
    }
}
