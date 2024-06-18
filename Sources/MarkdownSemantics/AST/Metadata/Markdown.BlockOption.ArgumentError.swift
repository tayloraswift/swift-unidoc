extension Markdown.BlockOption
{
    enum ArgumentError:Error
    {
        case enabledness(String)
        case duplicated(String)
        case unexpected(String)
    }
}
