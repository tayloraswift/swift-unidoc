extension Unicode.Scalar:HTML.OutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += self.utf8
    }
}
extension Unicode.Scalar:SVG.OutputStreamable
{
    @inlinable public static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg += self.utf8
    }
}
