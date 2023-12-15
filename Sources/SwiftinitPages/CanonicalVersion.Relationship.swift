extension CanonicalVersion
{
    @frozen @usableFromInline internal
    enum Relationship
    {
        case earlier
        case later
        case stable
    }
}
