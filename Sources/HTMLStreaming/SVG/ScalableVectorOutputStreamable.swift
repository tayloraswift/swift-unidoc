import HTMLDOM

public
protocol ScalableVectorOutputStreamable
{
    static
    func += (svg:inout SVG.ContentEncoder, self:Self)
}
extension ScalableVectorOutputStreamable where Self:StringProtocol
{
    @inlinable public static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg += self.utf8
    }
}
