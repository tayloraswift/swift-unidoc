import MarkdownAST

extension Markdown
{
    @frozen public
    enum SwiftFlavor
    {
    }
}
extension Markdown.SwiftFlavor:Markdown.ParsingFlavor
{
    /// Gives anchors to all level 2 and 3 headings.
    public static
    func process(toplevel block:Markdown.BlockElement)
    {
        if  case let block as Markdown.BlockHeading = block,
            case 2 ... 3 = block.level
        {
            block.anchor()
        }
    }

    public static
    subscript(instantiating directive:String) -> (any Markdown.BlockDirectiveType)?
    {
        switch directive
        {
        case "Code":                    Markdown.BlockCodeReference.init()
        case "Comment":                 nil as Markdown.BlockDirective?
        //  The @Column directive is actually row-like, because it appears **inside** a block
        //  of columns. Don’t know why Apple does this. Think different I guess.
        //
        //  @Column is supposed to get a default `size` of 1, but we would never use that value
        //  because it’s also the default in CSS.
        case "Column":                  Markdown.BlockDivision.init()
        case "ContentAndMedia":         Markdown.BlockDivision.init()
        case "DocumentationExtension":  Markdown.BlockMetadata.DocumentationExtension.init()
        case "Image":                   Markdown.BlockImage.init()
        case "Intro":                   Markdown.Tutorial.Intro.init()
        case "IsRoot":                  Markdown.BlockMetadata.IsRoot.init()
        case "Metadata":                Markdown.BlockMetadata.init()
        //  See note about @Column.
        case "Row":                     Markdown.BlockColumns.init()
        case "Section":                 Markdown.Tutorial.Section.init()
        case "Snippet":                 Markdown.BlockCodeFragment.init()
        case "Stack":                   Markdown.BlockColumns.init()
        case "Steps":                   Markdown.Tutorial.Steps.init()
        case "Step":                    Markdown.Tutorial.Step.init()
        case "TechnologyRoot":          Markdown.BlockMetadata.IsRoot.init()
        case "Tutorial":                Markdown.Tutorial.init()
        case "Video":                   Markdown.BlockVideo.init()
        case "XcodeRequirement":        Markdown.Tutorial.Requirement.init()
        case let name:                  Markdown.BlockDirective.init(name: name)
        }
    }
}
extension Markdown.SwiftFlavor
{
    /// Detects and breaks apart magical aside blocks.
    static
    func rewrite(
        child block:consuming Markdown.BlockElement,
        into blocks:inout [Markdown.BlockElement])
    {
        switch block
        {
        case let list as Markdown.BlockListUnordered:
            var items:[Markdown.BlockItem] = []
            for item:Markdown.BlockItem in list.elements
            {
                if  let prefix:Markdown.BlockPrefix = .extract(from: &item.elements),
                    case .keywords(let aside) = prefix
                {
                    blocks.append(aside(item.elements))
                }
                else
                {
                    items.append(item)
                }
            }
            if !items.isEmpty
            {
                list.elements = items
                blocks.append(list)
            }

        case let quote as Markdown.BlockQuote:
            if  case .keywords(let aside) = Markdown.BlockPrefix.extract(
                    from: &quote.elements)
            {
                blocks.append(aside(quote.elements))
            }
            else
            {
                blocks.append(quote)
            }

        case let block:
            blocks.append(block)
        }
    }
}
