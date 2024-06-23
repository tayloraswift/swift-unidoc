import HTML

extension Pie
{
    @frozen public
    struct Chart<Key> where Key:ChartKey
    {
        @usableFromInline
        let shape:Shape<Key>

        @inlinable
        init(shape:Shape<Key>)
        {
            self.shape = shape
        }
    }
}
extension Pie.Chart
{
    @inlinable public
    var legend:Legend { .init(shape: self.shape) }
}
extension Pie.Chart:HTML.OutputStreamable
{
    public
    static func += (figure:inout HTML.ContentEncoder, self:Self)
    {
        figure[.div] { $0.class = "pie" } = self.shape
        figure[.figcaption] { $0[.dl] = self.legend }
    }
}
