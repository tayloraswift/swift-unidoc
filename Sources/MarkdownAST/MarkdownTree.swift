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
    let blocks:[MarkdownBlock]

    @inlinable public
    init(parser parse:() -> [MarkdownBlock])
    {
        self.blocks = parse()
    }
}