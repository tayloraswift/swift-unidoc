extension Markdown
{
    /// A markdown flavor performs any post-processing that must be done after parsing
    /// a sequence of ``Markdown.BlockElement``s with a ``Markdown.ParsingEngine``.
    public
    protocol ParsingFlavor
    {
        static
        subscript(instantiating directive:String) -> (any Markdown.BlockDirectiveType)? { get }

        static
        func process(toplevel block:Markdown.BlockElement)
    }
}
