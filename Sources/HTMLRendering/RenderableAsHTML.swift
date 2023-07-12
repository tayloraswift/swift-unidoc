import HTML

public
protocol RenderableAsHTML
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
}
extension RenderableAsHTML where Self:StringProtocol
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        for codeunit:UInt8 in self.utf8
        {
            html.append(unescaped: codeunit)
        }
    }
}
