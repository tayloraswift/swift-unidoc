extension Swiftinit.Asset
{
    @frozen public
    enum Versioning:Comparable, Sendable
    {
        case none
        case major
        case minor
    }
}
