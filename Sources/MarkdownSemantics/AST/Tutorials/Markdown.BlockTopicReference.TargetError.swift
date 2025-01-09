extension Markdown.BlockTopicReference
{
    enum TargetError:Error
    {
        case doclink(String)
    }
}
extension Markdown.BlockTopicReference.TargetError:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .doclink(let link):
            """
            could not parse documentation link '\(link)'
            """
        }
    }
}
