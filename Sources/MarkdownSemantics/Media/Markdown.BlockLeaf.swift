import Sources

extension Markdown
{
    class BlockLeaf:BlockElement
    {
        var source:SourceReference<Markdown.Source>?

        override
        init()
        {
            self.source = nil
        }
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
