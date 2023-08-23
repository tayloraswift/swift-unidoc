import HTMLDOM

public
protocol HyperTextOutputStreamable
{
    /// Encodes an instance of this type to the provided HTML stream.
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
}
extension HyperTextOutputStreamable where Self:StringProtocol
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += self.utf8
    }
}
