import HTML
import Unidoc
import URI

struct DynamicVectorLink<Display, Scalars>
    where Display:Sequence, Scalars:Sequence<Unidoc.Scalar>
{
    private
    let display:Display
    private
    let scalars:Scalars
    private
    let inliner:Inliner

    init(display:Display, scalars:Scalars, inliner:Inliner)
    {
        self.display = display
        self.scalars = scalars
        self.inliner = inliner
    }
}
extension DynamicVectorLink:HyperTextOutputStreamable
    where Display.Element:HyperTextOutputStreamable
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

            html[link: self.inliner.uri(scalar)] = display
        }
    }
}
