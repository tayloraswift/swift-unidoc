extension HTML
{
    /// A value-representation of the ``subscript(link:_:)`` encoding interface.
    /// Use this type to reduce verbosity when encoding with rendering systems
    /// that generate the link’s display elements and the target together.
    @frozen public
    struct Link<Display>
    {
        public
        var display:Display
        public
        var target:String?

        @inlinable public
        init(display:Display, target:String?)
        {
            self.display = display
            self.target = target
        }
    }
}
extension HTML.Link:Equatable where Display:Equatable
{
}
extension HTML.Link:Sendable where Display:Sendable
{
}
extension HTML.Link:HyperTextOutputStreamable
    where Display:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[link: self.target] = self.display
    }
}
