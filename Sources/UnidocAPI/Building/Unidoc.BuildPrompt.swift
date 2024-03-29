import SemanticVersions
import Symbols
import URI

extension Unidoc
{
    @frozen public
    enum BuildPrompt:Sendable
    {
        /// Get a list of obsolete symbol graphs.
        case _allSymbolGraphs(upTo:PatchVersion, limit:Int?)

        /// Build a specific edition of a package.
        case edition(Edition)
        /// Build the latest version of a package.
        case package(Package, series:VersionSeries?)
        /// Build the latest version of a package by name.
        case packageNamed(Symbol.Package, series:VersionSeries?)
    }
}
extension Unidoc.BuildPrompt
{
    public
    init?(query:borrowing URI.Query)
    {
        var packageSymbol:Symbol.Package? = nil
        var package:Unidoc.Package? = nil
        var version:Unidoc.Version? = nil
        var series:Unidoc.VersionSeries? = nil

        var abi:PatchVersion? = nil
        var limit:Int?

        for (key, value) in query.parameters
        {
            switch key
            {
            case "package-symbol":  packageSymbol = .init(value)
            case "package":         package = .init(value)
            case "version":         version = .init(value)
            case "force":           series = .init(value)
            case "until":           abi = .init(value)
            case "limit":           limit = .init(value)
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
        else if
            let abi:PatchVersion
        {
            self = ._allSymbolGraphs(upTo: abi, limit: limit)
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
        case ._allSymbolGraphs(let abi, let limit?):
            ["until": "\(abi)", "limit": "\(limit)"]

        case ._allSymbolGraphs(let abi, nil):
            ["until": "\(abi)"]

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
