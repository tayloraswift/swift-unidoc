extension Never:HyperTextOutputStreamable
{
    @inlinable public static
    func += (_:inout HTML.ContentEncoder, _:Self)
    {
    }
}
extension Never:ScalableVectorOutputStreamable
{
    @inlinable public static
    func += (_:inout SVG.ContentEncoder, _:Self)
    {
    }
}
