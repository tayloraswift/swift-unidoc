import Sources

extension Markdown.BlockMetadata
{
    /// We hate technology, so we call this `IsRoot`.
    final
    class IsRoot:Markdown.BlockLeaf
    {
    }
}
extension Markdown.BlockMetadata.IsRoot:Markdown.BlockDirectiveType
{
    func configure(option:String, value _:Markdown.SourceString) throws
    {
        throw ArgumentError.unexpected(option)
    }
}
