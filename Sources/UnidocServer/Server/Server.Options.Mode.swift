import UnidocPages

extension Server.Options
{
    enum Mode
    {
        case development(cache:Cache<StaticAsset>, port:Int)
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
