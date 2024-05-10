import HTML
import UnidocRecords

extension Unidoc.IdentifiablePageContext
{
    @frozen public
    struct Tooltips
    {
        private
        let vertices:Table
        private
        let uris:[Unidoc.Scalar: String]
        private
        let list:[Unidoc.Scalar]

        init?(vertices:Table,
            uris:[Unidoc.Scalar: String],
            list:[Unidoc.Scalar])
        {
            if  list.isEmpty
            {
                return nil
            }

            self.vertices = vertices
            self.uris = uris
            self.list = list
        }
    }
}
extension Unidoc.IdentifiablePageContext.Tooltips:HTML.OutputStreamable
{
    public static
    func += (div:inout HTML.ContentEncoder, self:Self)
    {
        for id:Unidoc.Scalar in self.list
        {
            guard case (let vertex, principal: false)? = self.vertices[id],
            let uri:String = self.uris[id]
            else
            {
                continue
            }

            switch vertex
            {
            case .culture(let vertex):
                div[.a, { $0.href = uri }]
                {
                    $0[.pre, .code] = Unidoc.ImportSection.init(module: vertex.module.id)

                    $0 ?= vertex.overview?.markdown.safe
                }

            case .decl(let vertex):
                div[.a, { $0.href = uri }]
                {
                    $0[.pre, .code] = vertex.signature.expanded.bytecode.safe

                    $0 ?= vertex.overview?.markdown.safe
                }

            default:
                continue
            }
        }
    }
}
