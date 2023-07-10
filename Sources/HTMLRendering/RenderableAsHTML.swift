import HTML

public
protocol RenderableAsHTML
{
    func render(to html:inout HTML.ContentEncoder)
}
extension RenderableAsHTML where Self:StringProtocol
{
    @inlinable public
    func render(to html:inout HTML.ContentEncoder)
    {
        for codeunit:UInt8 in self.utf8
        {
            html.append(unescaped: codeunit)
        }
    }
}
