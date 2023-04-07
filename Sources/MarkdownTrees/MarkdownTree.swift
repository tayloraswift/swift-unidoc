import MarkdownABI

/// A reference to a markdown abstract syntax tree (AST).
///
/// While most swift library types have value semantics, markdown trees
/// have reference semantics. This is a deliberate choice, because
/// reference semantics are more amenable to the sort of “tree
/// manipulations” we often want to perform on this sort of data.
@frozen public
struct MarkdownTree
{
    public
    let blocks:[Block]

    @inlinable public
    init(blocks:[Block] = [])
    {
        self.blocks = blocks
    }
}
extension MarkdownTree
{
    /// Replaces symbolic codelinks in this markdown tree’s inline content
    /// with references.
    public
    func outline(by register:(_ symbol:String) throws -> UInt32) rethrows
    {
        for block:Block in self.blocks
        {
            if case let block as BlockContainer<InlineBlock> = block
            {
                for index:Int in block.elements.indices
                {
                    try block.elements[index].outline(by: register)
                }
            }
        }
    }
}
extension MarkdownTree
{
    /// Emits this markdown tree’s ``blocks`` into the given binary.
    /// In most cases, you don’t want to call this API directly, instead
    /// you may want to convert this tree into some higher-level semantic
    /// representation, and turn that into a binary instead.
    ///
    /// This function does not change any internal tree state.
    public
    func emit(into binary:inout MarkdownBinary)
    {
        for block:MarkdownTree.Block in self.blocks
        {
            block.emit(into: &binary)
        }
    }
}
