import HTML

extension HTML
{
    @inlinable public
    init(rendering value:some RenderableAsHTML)
    {
        self.init { $0 += value }
    }
}
