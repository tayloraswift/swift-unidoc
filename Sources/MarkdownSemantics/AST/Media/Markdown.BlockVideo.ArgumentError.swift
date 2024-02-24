extension Markdown.BlockVideo
{
    enum ArgumentError:Error
    {
        case duplicated(String)
        case unexpected(String)
    }
}
