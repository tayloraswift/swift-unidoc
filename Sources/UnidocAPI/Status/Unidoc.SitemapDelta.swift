extension Unidoc
{
    @frozen public
    struct SitemapDelta:Equatable, Sendable
    {
        public
        let deletions:[Shoot]
        public
        let additions:[Shoot]

        @inlinable public
        init(deletions:[Shoot], additions:[Shoot])
        {
            self.deletions = deletions
            self.additions = additions
        }
    }
}
extension Unidoc.SitemapDelta
{
    @inlinable public static
    var zero:Self { .init(deletions: [], additions: []) }
}
