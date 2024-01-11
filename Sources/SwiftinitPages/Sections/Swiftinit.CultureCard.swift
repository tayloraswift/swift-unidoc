import HTML
import UnidocRecords

extension Swiftinit
{
    struct CultureCard
    {
        let context:any Swiftinit.VertexPageContext

        let vertex:Unidoc.CultureVertex
        let target:String

        init(_ context:any Swiftinit.VertexPageContext,
            vertex:Unidoc.CultureVertex,
            target:String)
        {
            self.context = context
            self.vertex = vertex
            self.target = target
        }
    }
}
extension Swiftinit.CultureCard:Swiftinit.PreviewCard
{
    var passage:Unidoc.Passage? { self.vertex.overview }
}
extension Swiftinit.CultureCard:HTML.OutputStreamable
{
    static
    func += (li:inout HTML.ContentEncoder, self:Self)
    {
        li[.h3, { $0.class = "module" }]
        {
            $0[.a] { $0.href = self.target } = self.vertex.module.name

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
