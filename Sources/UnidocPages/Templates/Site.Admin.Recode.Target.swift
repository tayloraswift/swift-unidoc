extension Site.Admin.Recode
{
    @frozen public
    enum Target:String
    {
        case packages
        case editions
        case vertices
        case names
    }
}
extension Site.Admin.Recode.Target
{
    var label:String
    {
        switch self
        {
        case .packages:     return "Packages"
        case .editions:     return "Editions"
        case .vertices:     return "Vertices"
        case .names:        return "Volume Names"
        }
    }
}
