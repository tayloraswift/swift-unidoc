import HTML

extension Pie
{
    @frozen public
    struct Chart
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
extension Pie.Chart
{
    @inlinable public
    var legend:Pie<Key>.Legend { .init(shape: self.shape) }
}
extension Pie.Chart:HTML.OutputStreamable
{
    public static
    func += (figure:inout HTML.ContentEncoder, self:Self)
    {
        figure[.div] { $0.class = "pie" } = self.shape
        figure[.figcaption] { $0[.dl] = self.legend }
    }
}
