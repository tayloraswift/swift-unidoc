import Symbols

extension PackageManifest
{
    @frozen public
    enum DependencyPinError:Error, Equatable, Sendable
    {
        case duplicate(Symbol.Package)
        case undefined(Symbol.Package)
    }
}
