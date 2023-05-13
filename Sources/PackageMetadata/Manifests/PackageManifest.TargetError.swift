extension PackageManifest
{
    public
    enum TargetError:Error, Equatable, Sendable
    {
        case duplicate(String)
        case undefined(String)
    }
}
