import SemanticVersions
import Symbols
import URI

extension Unidoc
{
    @frozen public
    enum BuildLabelsPrompt:Sendable
    {
        /// Build a specific edition of a package.
        case edition(Edition)
        /// Build the latest version of a package.
        case package(Package, series:VersionSeries?)
        /// Build the latest version of a package by name.
        case packageNamed(Symbol.Package, series:VersionSeries?)
    }
}
extension Unidoc.BuildLabelsPrompt
{
    public
    init?(query:borrowing URI.Query)
    {
        var packageSymbol:Symbol.Package? = nil
        var package:Unidoc.Package? = nil
        var version:Unidoc.Version? = nil
        var series:Unidoc.VersionSeries? = nil

        for (key, value) in query.parameters
        {
            switch key
            {
            case "package-symbol":  packageSymbol = .init(value)
            case "package":         package = .init(value)
            case "version":         version = .init(value)
            case "force":           series = .init(value)
            default:                continue
            }
        }

        if  let package:Unidoc.Package,
            let version:Unidoc.Version
        {
            self = .edition(.init(package: package, version: version))
        }
        else if
            let package:Unidoc.Package,
            let series:Unidoc.VersionSeries
        {
            self = .package(package, series: series)
        }
        else if
            let packageSymbol:Symbol.Package,
            let series:Unidoc.VersionSeries
        {
            self = .packageNamed(packageSymbol, series: series)
        }
        else
        {
            return nil
        }
    }

    public
    var query:URI.Query
    {
        switch self
        {
        case .edition(let edition):
            ["package": "\(edition.package)", "version": "\(edition.version)"]

        case .package(let package, let series?):
            ["package": "\(package)", "force": "\(series)"]

        case .package(let package, nil):
            ["package": "\(package)"]

        case .packageNamed(let package, let series?):
            ["package-symbol": "\(package)", "force": "\(series)"]

        case .packageNamed(let package, nil):
            ["package-symbol": "\(package)"]
        }
    }
}
