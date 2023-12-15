import HTML

extension HTML
{
    @frozen public
    struct Logo
    {
        @inlinable public
        init()
        {
        }
    }
}
extension HTML.Logo:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.div, { $0.class = "logo" }]
        {
            $0[.a, { $0.href = "/" }] = "swiftinit"
        }
    }
}
