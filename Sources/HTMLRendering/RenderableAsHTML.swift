public
protocol RenderableAsHTML
{
    func render(to html:inout HTML)
}
extension String:RenderableAsHTML
{
    @inlinable public
    func render(to html:inout HTML)
    {
        html.utf8.append(contentsOf: self.utf8)
    }
}
