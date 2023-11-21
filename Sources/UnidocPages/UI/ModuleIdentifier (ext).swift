import HTML
import ModuleGraphs

extension ModuleIdentifier:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html += "\(self)"
    }
}
