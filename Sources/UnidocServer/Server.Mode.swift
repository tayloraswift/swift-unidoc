import UnidocPages

extension Server
{
    enum Mode
    {
        case development(Cache<StaticAsset>)
        case production
    }
}
extension Server.Mode
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
