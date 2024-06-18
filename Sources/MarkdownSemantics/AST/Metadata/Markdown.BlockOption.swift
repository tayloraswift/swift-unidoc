import Sources

extension Markdown
{
    final
    class BlockOption:Markdown.BlockLeaf
    {
        typealias Key = WritableKeyPath<
            Markdown.SemanticMetadata.Options,
            Markdown.SemanticMetadata.Option<Bool>?>

        let key:Key

        private(set)
        var value:Bool?

        init(key:Key)
        {
            self.key = key
            self.value = nil
            super.init()
        }
    }
}
extension Markdown.BlockOption:Markdown.BlockDirectiveType
{
    func configure(option:String, value:Markdown.SourceString) throws
    {
        switch option
        {
        case "":
            guard case nil = self.value
            else
            {
                throw ArgumentError.duplicated(option)
            }
            switch value.string
            {
            case "true", "enabled":
                self.value = true

            case "false", "disabled":
                self.value = false

            default:
                throw ArgumentError.enabledness(value.string)
            }

        case let option:
            throw ArgumentError.unexpected(option)
        }
    }
}
