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
