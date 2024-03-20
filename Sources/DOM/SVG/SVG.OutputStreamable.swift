extension SVG
{
    public
    protocol OutputStreamable
    {
        static
        func += (svg:inout SVG.ContentEncoder, self:Self)
    }
}
extension SVG.OutputStreamable where Self:StringProtocol
{
    @inlinable public static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg += self.utf8
    }
}
