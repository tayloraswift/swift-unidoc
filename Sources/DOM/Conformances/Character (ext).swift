extension Character:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += self.utf8
    }
}
extension Character:ScalableVectorOutputStreamable
{
    @inlinable public static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        svg += self.utf8
    }
}
