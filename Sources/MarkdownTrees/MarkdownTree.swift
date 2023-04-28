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
    init(attaching blocks:[Block] = [])
    {
        self.blocks = blocks
    }
}
extension MarkdownTree:MarkdownModel
{
    public
    func visit(_ yield:(Block) throws -> ()) rethrows
    {
        for block:Block in self.blocks
        {
            try yield(block)
        }
    }
}
