import HTMLDOM

infix operator ?= : AssignmentPrecedence

extension Optional where Wrapped:HyperTextOutputStreamable
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
extension Optional where Wrapped:ScalableVectorOutputStreamable
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
