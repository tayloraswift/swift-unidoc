import Symbols

extension Unidoc.PackageBuildOperation
{
    struct DirectParameters
    {
        let symbols:Symbol.PackageAtRef
        let package:Unidoc.Package
        let request:Unidoc.BuildRequest<Void>?

        private
        init(symbols:Symbol.PackageAtRef,
            package:Unidoc.Package,
            request:Unidoc.BuildRequest<Void>?)
        {
            self.symbols = symbols
            self.package = package
            self.request = request
        }
    }
}
extension Unidoc.PackageBuildOperation.DirectParameters
{
    init?(from form:borrowing [String: String])
    {
        guard
        let symbols:String = form["selector"],
        let package:String = form["package"],
        let package:Unidoc.Package = .init(package)
        else
        {
            return nil
        }

        let request:Unidoc.BuildRequest<Void>?

        switch form["build"]
        {
        case "request"?:
            let selector:Unidoc.BuildSelector<Void>

            if  let version:String = form["version"],
                let version:Unidoc.Version = .init(version)
            {
                selector = .id(.init(package: package, version: version))
            }
            else if
                case "prerelease"? = form["series"]
            {
                selector = .latest(.prerelease)
            }
            else
            {
                selector = .latest(.release)
            }

            request = .init(version: selector, rebuild: form["force"] == "true")

        case "cancel"?:
            request = nil

        default:
            return nil
        }

        self.init(symbols: .init(symbols), package: package, request: request)
    }
}
