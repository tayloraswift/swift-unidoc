import UnidocPages

extension Swiftinit.Options
{
    enum Mode
    {
        case development(Cache<Unidoc.RenderAsset>, Development)
        case production
    }
}
extension Swiftinit.Options.Mode
{
    var secured:Bool
    {
        switch self
        {
        case .development:  false
        case .production:   true
        }
    }
}