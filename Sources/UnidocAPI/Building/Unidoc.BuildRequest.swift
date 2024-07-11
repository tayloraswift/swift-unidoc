import SemanticVersions
import Symbols
import URI

extension Unidoc
{
    @frozen public
    struct BuildRequest<Package>
    {
        public
        let version:BuildSelector<Package>
        public
        let rebuild:Bool

        @inlinable public
        init(version:BuildSelector<Package>, rebuild:Bool)
        {
            self.version = version
            self.rebuild = rebuild
        }
    }
}
extension Unidoc.BuildRequest:Equatable where Package:Equatable
{
}
extension Unidoc.BuildRequest:Sendable where Package:Sendable
{
}
extension Unidoc.BuildRequest<Unidoc.Package>
{
    public
    init?(query:borrowing URI.Query)
    {
        var package:Unidoc.Package? = nil
        var version:Unidoc.Version? = nil
        var series:Unidoc.VersionSeries? = nil
        var force:Bool = false

        for (key, value) in query.parameters
        {
            switch key
            {
            case "package":         package = .init(value)
            case "version":         version = .init(value)
            case "series":          series = .init(value)
            case "force":           force = value == "true"
            default:                continue
            }
        }

        let selector:Unidoc.BuildSelector<Unidoc.Package>

        if  let package:Unidoc.Package,
            let version:Unidoc.Version
        {
            selector = .id(.init(package: package, version: version))
        }
        else if
            let package:Unidoc.Package,
            let series:Unidoc.VersionSeries
        {
            selector = .latest(series, of: package)
        }
        else
        {
            return nil
        }

        self.init(version: selector, rebuild: force)
    }

    public
    var query:URI.Query
    {
        switch self.version
        {
        case .id(let edition):
            [
                "package": "\(edition.package)",
                "version": "\(edition.version)",
                "force": "\(self.rebuild)"
            ]

        case .latest(let series, of: let package):
            ["package": "\(package)", "series": "\(series)", "force": "\(self.rebuild)"]
        }
    }
}
