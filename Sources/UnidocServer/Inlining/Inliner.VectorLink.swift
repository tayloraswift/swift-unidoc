import HTML
import Unidoc

extension Inliner
{
    struct VectorLink<Display, Scalars> where Display:Sequence, Scalars:Sequence<Unidoc.Scalar>
    {
        private
        let display:Display
        private
        let scalars:Scalars
        private
        let inliner:Inliner

        init(_ inliner:Inliner, display:Display, scalars:Scalars)
        {
            self.inliner = inliner

            self.display = display
            self.scalars = scalars
        }
    }
}
extension Inliner.VectorLink:HyperTextOutputStreamable
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

            html[link: self.inliner.url(scalar)] = display
        }
    }
}
