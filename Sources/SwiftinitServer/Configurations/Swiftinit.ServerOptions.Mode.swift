extension Swiftinit.ServerOptions
{
    enum Mode
    {
        case development(Cache<Swiftinit.Asset>, Development)
        case production(mirror:Bool)
    }
}
extension Swiftinit.ServerOptions.Mode
{
    var mirror:Bool
    {
        switch self
        {
        case .development:              false
        case .production(let mirror):   mirror
        }
    }
    var secure:Bool
    {
        switch self
        {
        case .development:  false
        case .production:   true
        }
    }
}
