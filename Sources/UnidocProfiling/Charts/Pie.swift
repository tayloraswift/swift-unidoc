import HTML

@frozen public
struct Pie<Key> where Key:PieSectorKey
{
    @usableFromInline internal
    var shape:Shape

    @inlinable internal
    init(shape:Shape)
    {
        self.shape = shape
    }
}
extension Pie:HTML.OutputStreamable
{
    public static
    func += (figure:inout HTML.ContentEncoder, self:Self)
    {
        figure[.div] { $0.class = "pie" } = self.shape
    }
}
