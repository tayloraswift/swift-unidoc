import HTMLDOM

extension Character:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += self.utf8
    }
}
