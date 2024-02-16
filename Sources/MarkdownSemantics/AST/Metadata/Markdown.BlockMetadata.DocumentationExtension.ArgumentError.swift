extension Markdown.BlockMetadata.DocumentationExtension
{
    enum ArgumentError:Error
    {
        case mergeBehavior(String)

        case duplicated(String)
        case unexpected(String)
    }
}
