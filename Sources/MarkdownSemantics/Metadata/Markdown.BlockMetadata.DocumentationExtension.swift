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
    func configure(option:String, value:String) throws
    {
        switch option
        {
        case "mergeBehavior":
            guard case nil = self.mergeBehavior
            else
            {
                throw ArgumentError.duplicated(option)
            }
            switch value
            {
            case "append":      self.mergeBehavior = .append
            case "override":    self.mergeBehavior = .override
            case let value:     throw ArgumentError.mergeBehavior(value)
            }

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
