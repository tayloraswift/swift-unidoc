import HTML
import UnidocRecords

extension Unidoc
{
    struct CultureCard:PreviewCard
    {
        let context:any VertexContext

        let vertex:CultureVertex
        let target:LinkTarget

        init(_ context:any VertexContext, vertex:CultureVertex, target:LinkTarget)
        {
            self.context = context
            self.vertex = vertex
            self.target = target
        }
    }
}
extension Unidoc.CultureCard:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.h3, { $0.class = "module" }]
        {
            $0[.a]
            {
                $0.tooltip = .declaration
                $0.link = self.target
            } = self.vertex.module.name

            let tag:String
            switch self.vertex.module.type
            {
            case .binary:       return
            case .executable:   tag = "executable"
            case .regular:      return
            case .macro:        tag = "macro"
            case .plugin:       tag = "plugin"
            case .snippet:      tag = "snippet"
            case .system:       tag = "system"
            case .test:         tag = "test"
            }

            $0[.span] { $0.class = "parenthetical" } = tag
        }

        li ?= self.overview
    }
}
