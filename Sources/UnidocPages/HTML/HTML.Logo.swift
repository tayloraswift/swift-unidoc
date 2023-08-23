import HTML

extension HTML
{
    struct Logo
    {
        init()
        {
        }
    }
}
extension HTML.Logo:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.div, { $0.class = "logo" }]
        {
            $0[.a, { $0.href = "/" }] = "swiftinit"
        }
    }
}
