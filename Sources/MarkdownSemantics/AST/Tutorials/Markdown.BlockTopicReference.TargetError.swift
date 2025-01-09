extension Markdown.BlockTopicReference
{
    enum TargetError:Error
    {
        case doclink(String)
    }
}
