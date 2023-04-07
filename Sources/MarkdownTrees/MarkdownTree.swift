import MarkdownABI

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
extension MarkdownTree
{
    /// Emits this markdown tree’s ``blocks`` into the given binary.
    /// In most cases, you don’t want to call this API directly, instead
    /// you may want to convert this tree into some higher-level semantic
    /// representation, and turn that into a binary instead.
    public
    func emit(into binary:inout MarkdownBinary)
    {
        for block:MarkdownTree.Block in self.blocks
        {
            block.emit(into: &binary)
        }
    }
}
