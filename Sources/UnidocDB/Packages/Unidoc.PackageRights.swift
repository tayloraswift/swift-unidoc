extension Unidoc
{
    @frozen public
    enum PackageRights:Comparable, Sendable
    {
        case reader
        case editor
        case owner
    }
}
