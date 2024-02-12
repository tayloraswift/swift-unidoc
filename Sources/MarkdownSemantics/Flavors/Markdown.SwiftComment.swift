import MarkdownAST

extension Markdown
{
    /// A variant of ``Markdown.SwiftFlavor`` that clips all headings to a maximum of `h2`.
    @frozen public
    enum SwiftComment
    {
    }
}
extension Markdown.SwiftComment:Markdown.ParsingFlavor
{
    /// Clips `h1` headings to `h2`.
    public static
    func process(toplevel block:Markdown.BlockElement)
    {
        if  case let heading as Markdown.BlockHeading = block
        {
            heading.clip(to: 2)
        }

        //  Anything ``Markdown.SwiftFlavor`` can do, we can do better
        Markdown.SwiftFlavor.process(toplevel: block)
    }

    public static
    subscript(instantiating directive:String) -> (any Markdown.BlockDirectiveType)?
    {
        //  Every legal block directive in a standalone article can also appear in a comment.
        Markdown.SwiftFlavor[instantiating: directive]
    }
}
