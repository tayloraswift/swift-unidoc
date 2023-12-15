extension Swiftinit.Options
{
    enum Mode
    {
        case development(Cache<Swiftinit.Asset>, Development)
        case production
    }
}
extension Swiftinit.Options.Mode
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
