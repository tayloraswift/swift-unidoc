import HTML

extension Pie
{
    @frozen @usableFromInline
    enum Shape<Key> where Key:ChartKey
    {
        case circle(Key, String)
        case slices([Slice])
    }
}
extension Pie.Shape:HTML.OutputStreamable
{
    @inlinable
    static func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.div, { $0.class = "pie-color" }]
        {
            $0[.svg, { $0.viewBox = "-1 -1 2 2" }]
            {
                $0[.g]
                {
                    switch self
                    {
                    case .circle(let key, let title):
                        $0[.circle]
                        {
                            $0.r = "1"
                            $0.class = key.id
                        }
                            content:
                        {
                            $0[.title] = title.isEmpty ? nil : title
                        }

                    case .slices(let slices):
                        for slice:Slice in slices
                        {
                            $0[.path] = slice
                        }
                    }
                }
            }
        }

        html[.div] { $0.class = "pie-geometry" }
    }
}
