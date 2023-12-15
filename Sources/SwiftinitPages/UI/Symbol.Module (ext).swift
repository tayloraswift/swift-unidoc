import HTML
import Symbols

extension Symbol.Module:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += "\(self)"
    }
}
