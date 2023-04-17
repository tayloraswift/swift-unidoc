extension Repository.Dependency
{
    @frozen public
    enum Requirement:Hashable, Equatable, Sendable
    {
        case range(Range<SemanticVersion>)
        case reference(Repository.Reference)
        case revision(Repository.Revision)
    }
}
