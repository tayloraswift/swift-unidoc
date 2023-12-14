import UnidocRecords

extension Unidoc.Sitemap
{
    @frozen public
    struct Delta:Equatable, Sendable
    {
        public
        let deletions:[Unidoc.Shoot]
        public
        let additions:Int

        @inlinable public
        init(deletions:[Unidoc.Shoot], additions:Int)
        {
            self.deletions = deletions
            self.additions = additions
        }
    }
}
extension Unidoc.Sitemap.Delta
{
    @inlinable public static
    var zero:Self { .init(deletions: [], additions: 0) }
}
