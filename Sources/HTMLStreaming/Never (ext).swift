import HTMLDOM

extension Never:HyperTextOutputStreamable
{
    @inlinable public static
    func += (_:inout HTML.ContentEncoder, _:Self)
    {
    }
}
