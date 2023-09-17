extension Site.Admin
{
    @frozen public
    enum Action:String, Equatable, Hashable, Sendable
    {
        case dropAccountDB = "drop-account-db"
        case dropPackageDB = "drop-package-db"
        case dropUnidocDB = "drop-unidoc-db"

        case recodePackageEditions = "recode-package-editions"
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
        case .dropPackageDB:            return "Drop Package Database"
        case .dropUnidocDB:             return "Drop Unidoc Database"
        case .recodePackageEditions:    return "Recode Package Editions"
        case .recodeUnidocVertices:     return "Recode Unidoc Vertices"
        case .rebuild:                  return "Rebuild Collections"
        case .upload:                   return "Upload Snapshots"
        }
    }
}
