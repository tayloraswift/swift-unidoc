import HTML
import Unidoc

extension HTML
{
    @frozen public
    struct VectorLink<Display, Scalars> where Display:Sequence, Scalars:Sequence<Unidoc.Scalar>
    {
        @usableFromInline
        let display:Display
        @usableFromInline
        let scalars:Scalars
        @usableFromInline
        let inliner:any Swiftinit.VersionedPageContext

        @inlinable public
        init(_ inliner:any Swiftinit.VersionedPageContext, display:Display, scalars:Scalars)
        {
            self.inliner = inliner

            self.display = display
            self.scalars = scalars
        }
    }
}
extension HTML.VectorLink where Display:Collection, Display.Element:StringProtocol
{
    @inlinable public
    var width:Int { self.display.reduce(self.display.count - 1) { $0 + $1.count } }
}
extension HTML.VectorLink:HyperTextOutputStreamable
    where Display.Element:HyperTextOutputStreamable
{
    @inlinable public static
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
