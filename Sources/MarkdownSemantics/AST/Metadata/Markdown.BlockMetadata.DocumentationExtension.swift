import Sources

extension Markdown.BlockMetadata
{
    final
    class DocumentationExtension:Markdown.BlockLeaf
    {
        private(set)
        var mergeBehavior:Markdown.SemanticMetadata.MergeBehavior?

        override
        init()
        {
            self.mergeBehavior = nil
            super.init()
        }
    }
}
extension Markdown.BlockMetadata.DocumentationExtension:Markdown.BlockDirectiveType
{
    enum Option:String, Markdown.BlockDirectiveOption
    {
        case mergeBehavior
    }

    func configure(option:Option, value:Markdown.SourceString) throws
    {
        switch option
        {
        case .mergeBehavior:
            guard case nil = self.mergeBehavior
            else
            {
                throw option.duplicate
            }

            self.mergeBehavior = try option.case(value)
        }
    }
}
