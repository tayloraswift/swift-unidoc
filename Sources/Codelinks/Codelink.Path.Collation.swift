extension Codelink.Path
{
    @frozen public
    enum Collation:Equatable, Hashable, Sendable
    {
        /// Legacy DocC collation, which uses case-folding.
        case legacy
    }
}
