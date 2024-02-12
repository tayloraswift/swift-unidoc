extension Markdown
{
    class BlockLeaf:BlockElement
    {
    }
}
extension Markdown.BlockLeaf
{
    /// Always throws a ``StructuralError.childUnexpected``, as this directive can never have
    /// any children.
    final
    func append(_:Markdown.BlockElement) throws
    {
        throw StructuralError.childUnexpected
    }
}
