import HTTP
import Media
import UnidocUI
import Unidoc

extension Unidoc.PackageAlignOperation
{
    enum Status
    {
        case align(Unidoc.PackageMetadata, to:Unidoc.Realm?)
        case noSuchPackage
        case noSuchRealm
    }
}
extension Unidoc.PackageAlignOperation.Status:HTTP.ServerEndpoint
{
    consuming
    func response(as _:Unidoc.RenderFormat) throws -> HTTP.ServerResponse
    {
        switch self
        {
        case .align(let package, to: _):
            .redirect(.seeOther("\(Unidoc.RefsEndpoint[package.symbol])"))

        case .noSuchPackage:
            .notFound("No such package")
        case .noSuchRealm:
            .notFound("No such realm")
        }
    }
}
