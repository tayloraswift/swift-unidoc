extension Markdown.BlockTopicReference
{
    enum ArgumentError:Error
    {
        case doclink(String)

        case duplicate(String)
        case unexpected(String)
    }
}
