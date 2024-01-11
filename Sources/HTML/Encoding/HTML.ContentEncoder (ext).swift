extension HTML.ContentEncoder
{
    /// Optionally encodes an ``HTML.OutputStreamable`` value to the stream through **multiple
    /// levels** of HTML tags, with optional attributes added to the **outermost** wrapper tag.
    ///
    /// If the value is nil, `attributes` will not be evaluated and nothing will be encoded.
    /// The getter always returns nil.
    @inlinable public
    subscript<Renderable>(
        _ exterior:HTML.ContainerElement,
        _ interior:HTML.ContainerElement...,
        exterior attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:HTML.OutputStreamable
    {
        get { nil }
        set (value)
        {
            if  let value:Renderable
            {
                self[exterior, { $0 += value ; attributes(&$0) }]
                {
                    for interior:HTML.ContainerElement in interior
                    {
                        $0.open(interior)
                    }

                    $0 += value

                    for interior:HTML.ContainerElement in interior.reversed()
                    {
                        $0.close(interior)
                    }
                }
            }
        }
    }

    /// Optionally encodes an ``HTML.OutputStreamable`` value to the stream through a **single**
    /// HTML tag, with optional attributes added to the wrapping tag.
    ///
    /// If the value is nil, `attributes` will not be evaluated and nothing will be encoded.
    /// The getter always returns nil.
    @inlinable public
    subscript<Renderable>(tag:HTML.ContainerElement,
        attributes:(inout HTML.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:HTML.OutputStreamable
    {
        get { nil }
        set (value)
        {
            if  let value:Renderable
            {
                self[tag, { $0 += value ; attributes(&$0) }] { $0 += value }
            }
        }
    }
}
extension HTML.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(svg:SVG.Embedded,
        attributes:(inout SVG.AttributeEncoder) -> () = { _ in }) -> Renderable?
        where Renderable:SVG.OutputStreamable
    {
        get { nil }
        set (value)
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
        where Renderable:HTML.OutputStreamable
    {
        get { nil }
        set (value)
        {
            if  let value:Renderable
            {
                self[link: target, { $0 += value ; attributes(&$0) }] { $0 += value }
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
