extension SVG
{
    public
    typealias OutputStreamable = _SVGOutputStreamable
}

@available(*, deprecated, renamed: "SVG.OutputStreamable")
public
typealias ScalableVectorOutputStreamable = SVG.OutputStreamable

/// The name of this protocol is ``SVG.OutputStreamable``.
public
protocol _SVGOutputStreamable
{
    static
    func += (svg:inout SVG.ContentEncoder, self:Self)
}
extension SVG.OutputStreamable where Self:StringProtocol
{
    @inlinable public static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg += self.utf8
    }
}
