import Sources

extension Markdown
{
    /// We intentionally avoid doing any specific metadata validation here, because we would
    /// like this block to support multiple metadata formats.
    final
    class BlockMetadata:BlockContainer<BlockElement>
    {
        var source:SourceReference<Markdown.Source>?

        init()
        {
            self.source = nil
            super.init([])
        }
    }
}
extension Markdown.BlockMetadata:Markdown.BlockDirectiveType
{
    /// Always throws an error, as this directive does not support any options.
    func configure(option:String, value _:Markdown.SourceString) throws
    {
        throw ArgumentError.unexpected(option)
    }
}
