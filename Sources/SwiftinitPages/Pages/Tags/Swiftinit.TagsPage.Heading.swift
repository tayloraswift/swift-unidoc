import HTML

extension Swiftinit.TagsPage
{
    enum Heading
    {
        case tags
        case settings
    }
}
extension Swiftinit.TagsPage.Heading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .tags:     "ss:tags"
        case .settings: "ss:settings"
        }
    }
}
extension Swiftinit.TagsPage.Heading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .tags:     "Package tags"
        case .settings: "Package settings"
        }
    }
}
