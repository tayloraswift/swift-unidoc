import HTML

extension HTML
{
    @inlinable public
    init(rendering value:some RenderableAsHTML)
    {
        self.init(with: value.render(to:))
    }
}
