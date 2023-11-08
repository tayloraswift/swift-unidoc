import UnidocPages

extension Server.Options
{
    enum Mode
    {
        case development(Cache<StaticAsset>, Development)
        case production
    }
}
extension Server.Options.Mode
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
