extension Markdown.BlockDivision
{
    enum ArgumentError:Error
    {
        case size(String)

        case duplicated(String)
        case unexpected(String)
    }
}
