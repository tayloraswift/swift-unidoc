import HTML
import Unidoc
import URI

extension Renderer.Link
{
    struct LazyVector<Scalars> where Display:Sequence, Scalars:Sequence<Unidoc.Scalar>
    {
        private
        let renderer:Renderer
        private
        let display:Display
        private
        let scalars:Scalars

        init(_ renderer:Renderer, display:Display, scalars:Scalars)
        {
            self.renderer = renderer
            self.display = display
            self.scalars = scalars
        }
    }
}
extension Renderer.Link.LazyVector:HyperTextOutputStreamable
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

            if  let uri:URI = self.renderer.uri(scalar)
            {
                html[.a, { $0[.href] = "\(uri)" }] = display
            }
            else
            {
                html[.span] = display
            }
        }
    }
}
