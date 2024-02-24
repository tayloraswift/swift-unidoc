extension Markdown.TutorialIndex.ExternalLinks
{
    enum ArgumentError:Error
    {
        case duplicated(String)
        case unexpected(String)
    }
}
