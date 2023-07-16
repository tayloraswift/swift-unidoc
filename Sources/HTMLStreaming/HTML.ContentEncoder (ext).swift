import HTMLDOM

extension HTML.ContentEncoder
{
    @inlinable internal static
    func += (self:inout Self, utf8:some Sequence<UInt8>)
    {
        for codeunit:UInt8 in utf8
        {
            self.append(unescaped: codeunit)
        }
    }
}
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
