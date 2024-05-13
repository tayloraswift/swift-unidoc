import HTML
import SymbolGraphs
import UnidocRecords
import UnidocRender

extension Unidoc.LinkReference<Unidoc.CultureVertex>:HTML.OutputStreamable
{
    @inlinable public static
    func += (code:inout HTML.ContentEncoder, self:Self)
    {
        code[.a] { $0.link = self.target } = self.vertex.module.id
    }
}
