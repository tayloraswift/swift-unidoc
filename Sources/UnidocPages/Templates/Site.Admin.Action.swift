extension Site.Admin
{
    @frozen public
    enum Action:String, Equatable, Hashable, Sendable
    {
        case dropAccountDB = "drop-account-db"
        case dropUnidocDB = "drop-unidoc-db"

        case lintUnidocEditions = "lint-unidoc-editions"

        case recodeUnidocRepos = "recode-unidoc-repos"
        case recodeUnidocEditions = "recode-unidoc-editions"
        case recodeUnidocVertices = "recode-unidoc-vertices"

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
        case .dropAccountDB:            return "Drop Account Database"
        case .dropUnidocDB:             return "Drop Unidoc Database"
        case .lintUnidocEditions:       return "Lint Editions"
        case .recodeUnidocRepos:        return "Recode Repos"
        case .recodeUnidocEditions:     return "Recode Editions"
        case .recodeUnidocVertices:     return "Recode Vertices"
        case .rebuild:                  return "Rebuild Collections"
        case .upload:                   return "Upload Snapshots"
        }
    }
}
