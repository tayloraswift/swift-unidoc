extension Markdown.BlockColumns
{
    enum ArgumentError:Error
    {
        case count(String)

        case duplicated(String)
        case unexpected(String)
    }
}
