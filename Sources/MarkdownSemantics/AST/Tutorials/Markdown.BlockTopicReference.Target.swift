extension Markdown.BlockTopicReference
{
    enum Target
    {
        case unresolved(Markdown.InlineAutolink)
        case resolved(Int)
    }
}
