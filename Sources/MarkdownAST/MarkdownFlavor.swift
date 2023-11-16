/// A markdown flavor performs any post-processing that must be done after parsing
/// a sequence of ``MarkdownBlock``s with a ``MarkdownParser``.
public
protocol MarkdownFlavor
{
    static
    func transform(blocks:inout [MarkdownBlock])
}
