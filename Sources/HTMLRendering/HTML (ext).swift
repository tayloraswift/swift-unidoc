import HTML

extension HTML
{
    @inlinable public
    init(rendering value:some RenderableAsHTML)
    {
        self.init(with: value.render(to:))
    }
}
extension HTML
{
    @inlinable public
    subscript<Renderable>(_ tag:ContainerElement,
        attributes:(inout AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:RenderableAsHTML
    {
        get
        {
            nil
        }
        set(value)
        {
            if  let value:Renderable
            {
                self[tag, attributes, content: value.render(to:)]
            }
        }
    }
}
