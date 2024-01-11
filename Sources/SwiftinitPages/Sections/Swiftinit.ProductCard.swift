import HTML
import UnidocRecords

extension Swiftinit
{
    struct ProductCard
    {
        let context:any Swiftinit.VertexPageContext

        let vertex:Unidoc.ProductVertex
        let target:String

        init(_ context:any Swiftinit.VertexPageContext,
            vertex:Unidoc.ProductVertex,
            target:String)
        {
            self.context = context
            self.vertex = vertex
            self.target = target
        }
    }
}
extension Swiftinit.ProductCard:Swiftinit.PreviewCard
{
    var passage:Unidoc.Passage? { nil }
}
extension Swiftinit.ProductCard:HTML.OutputStreamable
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
