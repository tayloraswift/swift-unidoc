import HTML
import Unidoc
import URI

extension Renderer
{
    struct Link<Display>
    {
        private
        let display:Display
        private
        let target:URI?

        init(display:Display, target:URI?)
        {
            self.display = display
            self.target = target
        }
    }
}
extension Renderer.Link:Equatable where Display:Equatable
{
}
extension Renderer.Link:Sendable where Display:Sendable
{
}
extension Renderer.Link:HyperTextOutputStreamable
    where Display:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        if  let uri:URI = self.target
        {
            html[.a, { $0[.href] = "\(uri)" }] = self.display
        }
        else
        {
            html[.span] = self.display
        }
    }
}
