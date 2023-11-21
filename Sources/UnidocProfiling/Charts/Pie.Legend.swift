import HTML

extension Pie
{
    @frozen public
    struct Legend
    {
        @usableFromInline internal
        let shape:Shape

        @inlinable internal
        init(shape:Shape)
        {
            self.shape = shape
        }
    }
}
extension Pie.Legend:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        switch self.shape
        {
        case .circle(let key, _):
            key.legend(&html, share: 1.0)

        case .slices(let slices):
            for slice:Pie<Key>.Slice in slices
            {
                slice.key.legend(&html, share: .init(slice.geometry.share))
            }
        }
    }
}
