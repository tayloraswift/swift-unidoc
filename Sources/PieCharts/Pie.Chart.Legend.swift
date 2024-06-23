import HTML

extension Pie.Chart
{
    @frozen public
    struct Legend
    {
        @usableFromInline
        let shape:Pie.Shape<Key>

        @inlinable
        init(shape:Pie.Shape<Key>)
        {
            self.shape = shape
        }
    }
}
extension Pie.Chart.Legend:HTML.OutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        switch self.shape
        {
        case .circle(let key, _):
            key.legend(&html, share: 1.0)

        case .slices(let slices):
            for slice:Pie.Shape<Key>.Slice in slices
            {
                slice.key.legend(&html, share: .init(slice.geometry.share))
            }
        }
    }
}
