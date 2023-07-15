import HTMLDOM

extension Unicode.Scalar:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += self.utf8
    }
}
