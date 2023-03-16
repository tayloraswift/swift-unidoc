import SemanticVersions

@frozen public
enum PackageRequirement:Hashable, Equatable, Sendable
{
    case range(Range<SemanticVersion>)
    case reference(GitReference)
    case revision(GitRevision)
}
