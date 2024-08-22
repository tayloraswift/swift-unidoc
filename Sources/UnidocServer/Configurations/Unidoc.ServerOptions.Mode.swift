import UnidocAssets
import UnidocRecords
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
    @inlinable public
    var security:Unidoc.Security
    {
        switch self
        {
        case .development(_, let options):  options.security
        case .production:                   .enforced
        }
    }

    @inlinable
    var server:Unidoc.ServerType
    {
        switch self
        {
        case .development(_, let options):  .localhost(port: options.port)
        case .production:                   .swiftinit_org
        }
    }
}
