import UnidocRecords

extension Realm.Sitemap
{
    @frozen public
    struct Delta:Equatable, Sendable
    {
        public
        let deletions:[Volume.Shoot]
        public
        let additions:Int

        @inlinable public
        init(deletions:[Volume.Shoot], additions:Int)
        {
            self.deletions = deletions
            self.additions = additions
        }
    }
}
extension Realm.Sitemap.Delta
{
    @inlinable public static
    var zero:Self { .init(deletions: [], additions: 0) }
}
