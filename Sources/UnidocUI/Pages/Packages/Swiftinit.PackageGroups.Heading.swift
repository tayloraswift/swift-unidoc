import HTML

extension Swiftinit.PackageGroups
{
    enum Heading
    {
        case realm
        case free
        case unfree
        case inactive
    }
}
extension Swiftinit.PackageGroups.Heading:Identifiable
{
    var id:String
    {
        switch self
        {
        case .realm:    "ss:realm-members"
        case .free:     "ss:free"
        case .unfree:   "ss:unfree"
        case .inactive: "ss:inactive"
        }
    }
}
extension Swiftinit.PackageGroups.Heading:HTML.OutputStreamableHeading
{
    var display:String
    {
        switch self
        {
        case .realm:    "Realm members"
        case .free:     "Free packages"
        case .unfree:   "Unfree packages"
        case .inactive: "Inactive packages"
        }
    }
}
