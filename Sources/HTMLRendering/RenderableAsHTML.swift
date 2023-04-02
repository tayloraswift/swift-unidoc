public
protocol RenderableAsHTML
{
    func render(to html:inout HTML)
}
extension RenderableAsHTML where Self:StringProtocol
{
    @inlinable public
    func render(to html:inout HTML)
    {
        for codeunit:UInt8 in self.utf8
        {
            html.append(unescaped: codeunit)
        }
    }
}
extension String:RenderableAsHTML
{
}
extension Substring:RenderableAsHTML
{
}
