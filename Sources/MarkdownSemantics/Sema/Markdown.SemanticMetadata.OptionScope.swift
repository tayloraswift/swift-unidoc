extension Markdown.SemanticMetadata
{
    @frozen public
    enum OptionScope:String, Equatable, Sendable
    {
        case local
        case global
    }
}
