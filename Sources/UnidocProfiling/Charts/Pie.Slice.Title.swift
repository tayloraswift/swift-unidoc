import HTML

extension Pie.Slice
{
    @frozen @usableFromInline internal
    struct Title
    {
        @usableFromInline internal
        let text:String

        @inlinable internal
        init(_ text:String)
        {
            self.text = text
        }
    }
}
extension Pie.Slice.Title:ScalableVectorOutputStreamable
{
    @inlinable internal static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg[.title] = self.text.isEmpty ? nil : self.text
    }
}
