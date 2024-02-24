extension Markdown.BlockImage
{
    enum ArgumentError:Error
    {
        case duplicated(String)
        case unexpected(String)
    }
}
