import HTML

extension Pie.Shape
{
    @frozen @usableFromInline
    struct Slice
    {
        @usableFromInline
        let geometry:Pie.ArcGeometry
        /// A tooltip to show when hovering over the sector.
        @usableFromInline
        let title:String
        @usableFromInline
        let key:Key

        @inlinable
        init(geometry:Pie.ArcGeometry, title:String, key:Key)
        {
            self.geometry = geometry
            self.title = title
            self.key = key
        }
    }
}
extension Pie.Shape.Slice:SVG.OutputStreamable
{
    @inlinable
    static func |= (path:inout SVG.AttributeEncoder, self:Self)
    {
        path.d = self.geometry.d
        path.class = self.key.id
    }

    @inlinable
    static func += (path:inout SVG.ContentEncoder, self:Self)
    {
        path[.title] = self.title.isEmpty ? nil : self.title
    }
}
