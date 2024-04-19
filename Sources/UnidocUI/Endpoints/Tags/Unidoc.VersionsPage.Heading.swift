import HTML

extension Unidoc.VersionsPage
{
    enum Heading
    {
        case tags
        case settings
        case settingsAdmin
    }
}
extension Unidoc.VersionsPage.Heading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .tags:             "ss:tags"
        case .settings:         "ss:settings"
        case .settingsAdmin:    "ss:settings-admin"
        }
    }
}
extension Unidoc.VersionsPage.Heading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .tags:             "Package tags"
        case .settings:         "Package settings"
        case .settingsAdmin:    "Admin actions"
        }
    }
}
