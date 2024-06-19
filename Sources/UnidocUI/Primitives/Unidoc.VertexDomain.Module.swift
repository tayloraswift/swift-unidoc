import HTML
import URI

extension Unidoc.VertexDomain
{
    struct Module
    {
        let name:Substring
        let url:String

        init(name:Substring, url:String)
        {
            self.name = name
            self.url = url
        }
    }
}
extension Unidoc.VertexDomain.Module
{
    init?(from link:Unidoc.LinkReference<Unidoc.CultureVertex>)
    {
        guard
        let url:String = link.target?.url
        else
        {
            return nil
        }

        self.init(name: link.vertex.module.name[...], url: url)
    }
}
extension Unidoc.VertexDomain.Module:HTML.OutputStreamable
{
    static
    func += (span:inout HTML.ContentEncoder, self:Self)
    {
        span[.a] { $0.href = self.url } = self.name
    }
}
