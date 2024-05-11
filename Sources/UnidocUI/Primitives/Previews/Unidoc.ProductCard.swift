import HTML
import UnidocRecords

extension Unidoc
{
    struct ProductCard:PreviewCard
    {
        let context:any VertexContext

        let vertex:ProductVertex
        let target:String

        init(_ context:any VertexContext,
            vertex:ProductVertex,
            target:String)
        {
            self.context = context
            self.vertex = vertex
            self.target = target
        }
    }
}
extension Unidoc.ProductCard:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.h3, { $0.class = "product" }]
        {
            $0[.a] { $0.href = self.target } = self.vertex.symbol

            let tag:String
            switch self.vertex.type
            {
            case .executable:   tag = "executable"
            case .library:      tag = "library"
            case .macro:        tag = "macro"
            case .plugin:       tag = "plugin"
            case .snippet:      tag = "snippet"
            case .test:         tag = "test"
            }

            $0[.span] { $0.class = "parenthetical" } = tag
        }
        li ?= self.overview
    }
}
