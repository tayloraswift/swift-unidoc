extension Markdown.BlockCodeReference
{
    enum ArgumentError:Error
    {
        case path(String)
        case name(String?, available:[String])
        case slice(String, available:[String])

        case duplicated(String)
        case unexpected(String)
    }
}
