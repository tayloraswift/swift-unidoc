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
        case "Comment":         nil as Markdown.BlockDirective?
        case "ContentAndMedia": Markdown.BlockRows.init()
        case "Image":           Markdown.BlockImage.init()
        case "Intro":           Markdown.Tutorial.Intro.init()
        case "Section":         Markdown.Tutorial.Section.init()
        case "Snippet":         Markdown.BlockCodeReference.init()
        case "Stack":           Markdown.BlockColumns.init()
        case "Steps":           Markdown.Tutorial.Steps.init()
        case "Step":            Markdown.Tutorial.Step.init()
        case "Tutorial":        Markdown.Tutorial.init()
        case "Video":           Markdown.BlockVideo.init()
        default:                Markdown.BlockDirective.init(name: directive)
        }
    }
}
