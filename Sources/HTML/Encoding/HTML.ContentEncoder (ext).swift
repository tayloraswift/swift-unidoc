extension HTML.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(_ tag:HTML.ContainerElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:HyperTextOutputStreamable
    {
        get
        {
            nil
        }
        set(value)
        {
            if  let value:Renderable
            {
                self[tag, attributes] { $0 += value }
            }
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(svg:SVG.Embedded,
        attributes:(inout SVG.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:ScalableVectorOutputStreamable
    {
        get
        {
            nil
        }
        set(value)
        {
            if  let value:Renderable
            {
                self[svg, attributes] { $0 += value }
            }
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(link target:String?,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:HyperTextOutputStreamable
    {
        get
        {
            nil
        }
        set(display)
        {
            if  let display:Renderable
            {
                self[link: target, attributes] { $0 += display }
            }
        }
    }
}
extension HTML.ContentEncoder
{
    /// Appends a `span` element to the stream if the link `target` is nil,
    /// or an `a` element containing the link `target` in its `href` attribute
    /// if non-nil.
    @inlinable public
    subscript(link target:String?,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in },
        content encode:(inout Self) -> ()) -> Void
    {
        mutating get
        {
            if  let target:String
            {
                self[.a, { $0.href = target ; attributes(&$0) }, content: encode]
            }
            else
            {
                self[.span, attributes, content: encode]
            }
        }
    }
}
