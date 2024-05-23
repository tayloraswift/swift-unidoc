extension Unidoc
{
    enum VersionSelector:Sendable
    {
        case match(VersionPredicate)
        case exact(Version)
    }
}
