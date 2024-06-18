import Sources

extension Markdown
{
    /// We intentionally avoid doing any specific metadata validation here, because we would
    /// like this block to support multiple metadata formats.
    final
    class BlockOptions:BlockContainer<BlockElement>
    {
        var source:SourceReference<Markdown.Source>?

        private(set)
        var scope:SemanticMetadata.OptionScope?

        init()
        {
            self.source = nil
            self.scope = nil
            super.init([])
        }
    }
}
extension Markdown.BlockOptions:Markdown.BlockDirectiveType
{
    func configure(option:String, value:Markdown.SourceString) throws
    {
        switch option
        {
        case "scope":
            guard case nil = self.scope
            else
            {
                throw ArgumentError.duplicated(option)
            }
            guard
            let scope:Markdown.SemanticMetadata.OptionScope = .init(rawValue: value.string)
            else
            {
                throw ArgumentError.scope(value.string)
            }

            self.scope = scope

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
