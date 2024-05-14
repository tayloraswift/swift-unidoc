import HTML

extension Unidoc.UserSettingsPage
{
    enum Heading
    {
        case profile
        case repositories
        case organizations
        case apiKeys
    }
}
extension Unidoc.UserSettingsPage.Heading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .profile:          "ss:profile"
        case .repositories:     "ss:repositories"
        case .organizations:    "ss:organizations"
        case .apiKeys:          "ss:api-keys"
        }
    }
}
extension Unidoc.UserSettingsPage.Heading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .profile:          "GitHub Profile"
        case .repositories:     "Repositories"
        case .organizations:    "Organizations"
        case .apiKeys:          "API keys"
        }
    }
}
