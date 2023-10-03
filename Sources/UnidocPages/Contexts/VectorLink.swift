import HTML
import Unidoc

struct VectorLink<Display, Scalars> where Display:Sequence, Scalars:Sequence<Unidoc.Scalar>
{
    private
    let display:Display
    private
    let scalars:Scalars
    private
    let inliner:VersionedPageContext

    init(_ inliner:VersionedPageContext, display:Display, scalars:Scalars)
    {
        self.inliner = inliner

        self.display = display
        self.scalars = scalars
    }
}
extension VectorLink:HyperTextOutputStreamable where Display.Element:HyperTextOutputStreamable
{
    static
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
