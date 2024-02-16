extension Markdown.Tutorials.ExternalLinks
{
    enum ArgumentError:Error
    {
        case duplicated(String)
        case unexpected(String)
    }
}
