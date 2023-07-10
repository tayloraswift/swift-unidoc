import HTML

extension HTML.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(_ tag:HTML.ContainerElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Renderable?
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
