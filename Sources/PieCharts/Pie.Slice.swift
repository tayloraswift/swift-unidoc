import HTML

extension Pie
{
    @frozen @usableFromInline internal
    struct Slice
    {
        @usableFromInline internal
        let geometry:Geometry
        /// A tooltip to show when hovering over the sector.
        @usableFromInline internal
        let title:Title
        @usableFromInline internal
        let key:Key

        @inlinable internal
        init(geometry:Geometry, title:Title, key:Key)
        {
            self.geometry = geometry
            self.title = title
            self.key = key
        }
    }
}
