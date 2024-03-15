extension Swiftinit.ServerOptions
{
    enum Mode
    {
        case development(Cache<Swiftinit.Asset>, Development)
        case production
    }
}
extension Swiftinit.ServerOptions.Mode
{
    var secure:Bool
    {
        switch self
        {
        case .development:  false
        case .production:   true
        }
    }
}
