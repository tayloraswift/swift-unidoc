@frozen public
struct MarkdownTree
{
    public
    var blocks:[Block]

    @inlinable public
    init(blocks:[Block] = [])
    {
        self.blocks = blocks
    }
}
