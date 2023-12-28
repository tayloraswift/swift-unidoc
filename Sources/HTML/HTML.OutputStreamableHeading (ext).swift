extension HTML.OutputStreamableHeading
{
    @inlinable public static
    func += (hx:inout HTML.ContentEncoder, self:Self)
    {
        hx[.a] { $0.href = "#\(self.id)" } = self.display
    }
}
