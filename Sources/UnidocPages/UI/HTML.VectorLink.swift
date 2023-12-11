import HTML
import Unidoc

extension HTML
{
    @frozen public
    struct VectorLink<Display, Scalars> where Display:Sequence, Scalars:Sequence<Unidoc.Scalar>
    {
        private
        let display:Display
        private
        let scalars:Scalars
        private
        let inliner:any VersionedPageContext

        init(_ inliner:any VersionedPageContext, display:Display, scalars:Scalars)
        {
            self.inliner = inliner

            self.display = display
            self.scalars = scalars
        }
    }
}
extension HTML.VectorLink where Display:Collection, Display.Element:StringProtocol
{
    var width:Int { self.display.reduce(self.display.count - 1) { $0 + $1.count } }
}
extension HTML.VectorLink:HyperTextOutputStreamable
    where Display.Element:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        var first:Bool = true
        for (scalar, display):(Unidoc.Scalar, Display.Element) in zip(
            self.scalars,
            self.display)
        {
            if  first
            {
                first = false
            }
            else
            {
                html += "."
            }

            html[link: self.inliner.url(scalar)] = display
        }
    }
}
