extension Never:HTML.OutputStreamable
{
    @inlinable public static
    func += (_:inout HTML.ContentEncoder, _:Self)
    {
    }
}
extension Never:SVG.OutputStreamable
{
    @inlinable public static
    func += (_:inout SVG.ContentEncoder, _:Self)
    {
    }
}
