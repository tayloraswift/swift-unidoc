import HTML
import Symbols

extension Symbol.Module:HTML.OutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += "\(self)"
    }
}
