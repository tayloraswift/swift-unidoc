import HTML
import SymbolGraphs
import UnidocRecords
import UnidocRender

extension Unidoc.LinkReference<Unidoc.CultureVertex>:HTML.OutputStreamable
{
    @inlinable public static
    func += (code:inout HTML.ContentEncoder, self:Self)
    {
        code[link: self.target?.location] = self.vertex.module.id
    }
}
