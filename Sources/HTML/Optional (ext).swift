extension Optional where Wrapped:HTML.OutputStreamable
{
    @inlinable public static
    func ?= (html:inout HTML.ContentEncoder, wrapped:Wrapped?)
    {
        if  let wrapped:Wrapped
        {
            html += wrapped
        }
    }
}
extension Optional where Wrapped:SVG.OutputStreamable
{
    @inlinable public static
    func ?= (svg:inout SVG.ContentEncoder, wrapped:Wrapped?)
    {
        if  let wrapped:Wrapped
        {
            svg += wrapped
        }
    }
}
