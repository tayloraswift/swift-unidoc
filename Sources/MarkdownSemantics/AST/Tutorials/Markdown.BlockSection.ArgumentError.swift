extension Markdown.BlockSection
{
    enum ArgumentError:Error
    {
        case duplicated(String)
        case unexpected(String)
    }
}
