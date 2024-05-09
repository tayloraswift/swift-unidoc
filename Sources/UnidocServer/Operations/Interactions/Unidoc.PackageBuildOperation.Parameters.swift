extension Unidoc.PackageBuildOperation
{
    struct Parameters
    {
        let selector:Unidoc.VolumeSelector
        let package:Unidoc.Package
        let request:Unidoc.BuildRequest?

        private
        init(selector:Unidoc.VolumeSelector,
            package:Unidoc.Package,
            request:Unidoc.BuildRequest?)
        {
            self.selector = selector
            self.package = package
            self.request = request
        }
    }
}
extension Unidoc.PackageBuildOperation.Parameters
{
    init?(from form:borrowing [String: String])
    {
        guard
        let selector:String = form["selector"],
        let package:String = form["package"],
        let package:Unidoc.Package = .init(package)
        else
        {
            return nil
        }

        let request:Unidoc.BuildRequest?

        switch form["build"]
        {
        case "request"?:
            if  let version:String = form["version"],
                let version:Unidoc.Version = .init(version)
            {
                request = .id(.init(package: package, version: version))
                break
            }

            let series:Unidoc.VersionSeries
            if  case "prerelease"? = form["series"]
            {
                series = .prerelease
            }
            else
            {
                series = .release
            }

            request = .latest(series, force: form["force"] == "true")

        case "cancel"?:
            request = nil

        default:
            return nil
        }

        self.init(selector: .init(selector), package: package, request: request)
    }
}
