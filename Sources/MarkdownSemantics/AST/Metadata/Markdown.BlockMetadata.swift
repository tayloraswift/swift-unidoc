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
    func configure(option:Markdown.NeverOption, value _:Markdown.SourceString)
    {
    }
}
