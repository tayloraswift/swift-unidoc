@frozen public
struct MarkdownTree
{
    public
    var blocks:[Block]

    @inlinable public
    init(_ blocks:[Block])
    {
        self.blocks = blocks
    }
}
