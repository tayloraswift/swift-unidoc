import HTML

extension Unidoc.VersionsPage
{
    enum Heading
    {
        case tags
        case branches
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
        case .branches:         "ss:branches"
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
        case .branches:         "Package branches"
        case .settings:         "Package settings"
        case .settingsAdmin:    "Admin actions"
        }
    }
}
