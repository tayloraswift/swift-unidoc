import ModuleGraphs

extension Repository
{
    @frozen public
    enum PinError:Error, Equatable, Sendable
    {
        case duplicate(PackageIdentifier)
        case undefined(PackageIdentifier)
    }
}
