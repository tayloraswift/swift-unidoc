import HTML

extension Pie
{
    @frozen @usableFromInline internal
    enum Shape
    {
        case circle(Key, Slice.Title)
        case slices([Slice])
    }
}
extension Pie.Shape:HTML.OutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.div, { $0.class = "pie-color" }]
        {
            $0[.svg] { $0.viewBox = "-1 -1 2 2" } = self
        }

        html[.div] { $0.class = "pie-geometry" }
    }
}
extension Pie.Shape:SVG.OutputStreamable
{
    @inlinable public static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg[.g]
        {
            switch self
            {
            case .circle(let key, let title):
                $0[.circle] { $0.r = "1" ; $0.class = key.id } = title

            case .slices(let slices):
                for slice:Pie<Key>.Slice in slices
                {
                    $0[.path]
                    {
                        $0.d = slice.geometry.d
                        $0.class = slice.key.id
                    } = slice.title
                }
            }
        }
    }
}
