extension Swiftinit.SourceLink
{
    enum Icon
    {
        case github
    }
}
extension Swiftinit.SourceLink.Icon:Identifiable
{
    var id:String
    {
        switch self
        {
        case .github:   "github"
        }
    }
}
