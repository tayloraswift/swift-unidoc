extension Unidoc
{
    @frozen public
    struct SitemapDelta:Equatable, Sendable
    {
        public
        let deletions:[Shoot]
        public
        let additions:Int

        @inlinable public
        init(deletions:[Shoot], additions:Int)
        {
            self.deletions = deletions
            self.additions = additions
        }
    }
}
extension Unidoc.SitemapDelta
{
    @inlinable public static
    var zero:Self { .init(deletions: [], additions: 0) }
}
