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
        case "Comment":             nil as Markdown.BlockDirective?
        //  The @Column directive is actually row-like, because it appears **inside** a block
        //  of columns. Don’t know why Apple does this. Think different I guess.
        //
        //  @Column is supposed to get a default `size` of 1, but we would never use that value
        //  because it’s also the default in CSS.
        case "Column":              Markdown.BlockDivision.init()
        case "ContentAndMedia":     Markdown.BlockDivision.init()
        case "Image":               Markdown.BlockImage.init()
        case "Intro":               Markdown.Tutorial.Intro.init()
        //  See note about @Column.
        case "Row":                 Markdown.BlockColumns.init()
        case "Section":             Markdown.Tutorial.Section.init()
        case "Snippet":             Markdown.BlockCodeReference.init()
        case "Stack":               Markdown.BlockColumns.init()
        case "Steps":               Markdown.Tutorial.Steps.init()
        case "Step":                Markdown.Tutorial.Step.init()
        case "Tutorial":            Markdown.Tutorial.init()
        case "Video":               Markdown.BlockVideo.init()
        case "XcodeRequirement":    Markdown.Tutorial.Requirement.init()
        case let name:              Markdown.BlockDirective.init(name: name)
        }
    }
}
