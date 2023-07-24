import HTML
import Unidoc

extension Inliner
{
    struct Breadcrumbs
    {
        private
        let scope:VectorLink<ArraySlice<String>, [Unidoc.Scalar]>?
        private
        let last:String

        init(
            _ scope:VectorLink<ArraySlice<String>, [Unidoc.Scalar]>?,
            _ last:String)
        {
            self.scope = scope
            self.last = last
        }
    }
}
extension Inliner.Breadcrumbs:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.div, { $0.class = "breadcrumbs" }]
        {
            if  let scope:Inliner.VectorLink<ArraySlice<String>, [Unidoc.Scalar]> = self.scope
            {
                $0 += scope
                $0 += "."
            }

            $0[.span] = self.last
        }
    }
}
