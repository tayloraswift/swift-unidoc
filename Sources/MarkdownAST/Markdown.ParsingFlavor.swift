extension Markdown
{
    /// A markdown flavor performs any post-processing that must be done after parsing
    /// a sequence of ``Markdown.BlockElement``s with a ``Markdown.ParsingEngine``.
    public
    typealias ParsingFlavor = _MarkdownParsingFlavor
}
/// The name of this protocol is ``Markdown.ParsingFlavor``.
public
protocol _MarkdownParsingFlavor
{
    static
    subscript(instantiating directive:String) -> (any Markdown.BlockDirectiveType)? { get }

    static
    func process(toplevel block:Markdown.BlockElement)
}
