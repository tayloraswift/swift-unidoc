extension Markdown.BlockCodeFragment
{
    enum ArgumentError:Error
    {
        case snippet(String?, available:[String])
        case slice(String, available:[String])
        case path(String)

        case duplicated(String)
        case unexpected(String)
    }
}
