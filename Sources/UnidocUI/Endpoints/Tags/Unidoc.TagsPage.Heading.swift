import HTML

extension Unidoc.TagsPage
{
    enum Heading
    {
        case prereleases
        case releases
        case tags
        case settings
        case settingsAdmin
    }
}
extension Unidoc.TagsPage.Heading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .prereleases:      "ss:prereleases"
        case .releases:         "ss:releases"
        case .tags:             "ss:tags"
        case .settings:         "ss:settings"
        case .settingsAdmin:    "ss:settings-admin"
        }
    }
}
extension Unidoc.TagsPage.Heading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .prereleases:      "Prereleases"
        case .releases:         "Releases"
        case .tags:             "Package tags"
        case .settings:         "Package settings"
        case .settingsAdmin:    "Admin actions"
        }
    }
}
