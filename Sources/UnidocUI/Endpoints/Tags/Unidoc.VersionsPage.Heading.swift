import HTML

extension Unidoc.VersionsPage
{
    enum Heading
    {
        case tags
        case branches
        case consumers
        case settings
        case settingsAdmin
        case importRefs
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
        case .consumers:        "ss:consumers"
        case .settings:         "ss:settings"
        case .settingsAdmin:    "ss:settings-admin"
        case .importRefs:       "ss:import-refs"
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
        case .consumers:        "Consumers"
        case .settings:         "Settings"
        case .settingsAdmin:    "Admin actions"
        case .importRefs:       "Add branches"
        }
    }
}
