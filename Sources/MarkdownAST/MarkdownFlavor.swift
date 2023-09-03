public
protocol MarkdownFlavor
{
    static
    func transform(blocks:inout [MarkdownBlock])
}
