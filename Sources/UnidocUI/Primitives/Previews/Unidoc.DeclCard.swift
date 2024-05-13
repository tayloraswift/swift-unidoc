import HTML
import UnidocRecords

extension Unidoc
{
    struct DeclCard:PreviewCard
    {
        let context:any VertexContext

        let vertex:DeclVertex
        let target:LinkTarget

        init(_ context:any VertexContext, vertex:DeclVertex, target:LinkTarget)
        {
            self.context = context
            self.vertex = vertex
            self.target = target
        }
    }
}
extension Unidoc.DeclCard:HTML.OutputStreamableAnchor
{
    var id:String { "\(self.vertex.symbol)" }
}
extension Unidoc.DeclCard:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.a] { $0.href = "#\(self.id)" }
        //  There is no better way to compute the monospace width of markdown than
        //  rendering it to plain text and performing grapheme breaking.
        let width:Int = "\(self.vertex.signature.abridged.bytecode.safe)".count

        //  The em width of a single glyph of the IBM Plex Mono font is 600 / 1000,
        //  or 0.6. We consider a signature to be “long” if it occupies more than
        //  48 em units. Therefore the threshold is 48 / 0.6 = 80 characters.
        li[.code]
        {
            $0.class = width > 80 ? "multiline decl" : "decl"
        }
            content:
        {
            $0[.a]
            {
                $0.tooltip = .declaration
                $0.link = self.target
                $0.class = self.vertex.signature.availability.isGenerallyRecommended ?
                    nil : "discouraged"
            } = self.vertex.signature.abridged
        }

        li ?= self.overview
    }
}
