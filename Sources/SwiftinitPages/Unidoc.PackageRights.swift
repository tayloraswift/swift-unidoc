extension Unidoc
{
    @frozen public
    enum PackageRights:Comparable
    {
        case reader
        case editor
        case owner
    }
}
