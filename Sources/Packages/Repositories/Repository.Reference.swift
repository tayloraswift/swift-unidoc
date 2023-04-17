extension Repository
{
    /// A git reference.
    @frozen public 
    enum Reference:Hashable, Equatable, Sendable
    {
        case version(SemanticVersion)
        case branch(String)
    }
}
