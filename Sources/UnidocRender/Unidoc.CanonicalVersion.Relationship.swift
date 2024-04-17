extension Unidoc.CanonicalVersion
{
    @frozen public
    enum Relationship
    {
        case earlier
        case later
        case stable
    }
}
