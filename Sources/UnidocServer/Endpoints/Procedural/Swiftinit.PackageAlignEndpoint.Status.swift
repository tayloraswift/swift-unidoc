import HTTP
import Unidoc
import UnidocPages
import Media

extension Swiftinit.PackageAlignEndpoint
{
    enum Status
    {
        case align(Unidoc.Package, to:Unidoc.Realm?)
        case noSuchPackage
        case noSuchRealm
    }
}
extension Swiftinit.PackageAlignEndpoint.Status:HTTP.ServerResponseFactory
{
    func response(with assets:StaticAssets, as media:AcceptType) throws -> HTTP.ServerResponse
    {
        switch self
        {
        case .align:            .ok("Operation in progress")
        case .noSuchPackage:    .notFound("No such package")
        case .noSuchRealm:      .notFound("No such realm")
        }
    }
}
