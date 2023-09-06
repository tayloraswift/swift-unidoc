extension Site.Admin
{
    @frozen public
    enum Action:String, Equatable, Hashable, Sendable
    {
        case dropAccountDB = "drop-account-db"
        case dropUnidocDB = "drop-unidoc-db"
        case rebuild = "rebuild"
        case upload = "upload"
    }
}
extension Site.Admin.Action
{
    var label:String
    {
        switch self
        {
        case .dropAccountDB:    return "Drop Account Database"
        case .dropUnidocDB:     return "Drop Unidoc Database"
        case .rebuild:          return "Rebuild Collections"
        case .upload:           return "Upload Snapshots"
        }
    }
}
