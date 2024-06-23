import HTML

extension Pie
{
    @frozen public
    struct Disc<Key> where Key:ChartKey
    {
        @usableFromInline
        var shape:Shape<Key>

        @inlinable
        init(shape:Shape<Key>)
        {
            self.shape = shape
        }
    }
}
extension Pie.Disc:HTML.OutputStreamable
{
    public static
    func += (figure:inout HTML.ContentEncoder, self:Self)
    {
        figure[.div] { $0.class = "pie" } = self.shape
    }
}
