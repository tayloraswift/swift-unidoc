extension Markdown.BlockOptions
{
    enum ArgumentError:Error
    {
        case scope(String)

        case duplicated(String)
        case unexpected(String)
    }
}
