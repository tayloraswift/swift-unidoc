import Repositories

extension PackageManifest
{
    public
    enum TargetError:Error, Equatable, Sendable
    {
        case duplicate(TargetIdentifier)
        case undefined(TargetIdentifier)
    }
}
