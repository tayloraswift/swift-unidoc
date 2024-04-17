import UnidocAssets
import UnidocRender

extension Unidoc.ServerOptions
{
    @frozen public
    enum Mode:Sendable
    {
        case development(Unidoc.Cache<Unidoc.Asset>, Development)
        case production
    }
}
extension Unidoc.ServerOptions.Mode
{
    @inlinable
    var server:Unidoc.RenderFormat.Server
    {
        switch self
        {
        case .development(_, let options):  .localhost(port: options.port)
        case .production:                   .swiftinit_org
        }
    }
}
