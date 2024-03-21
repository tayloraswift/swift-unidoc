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
    var server:Swiftinit.RenderFormat.Server
    {
        switch self
        {
        case .development(_, let options):  .localhost(port: options.port)
        case .production:                   .swiftinit_org
        }
    }
}
