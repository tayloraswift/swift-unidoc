import HTMLDOM

extension SVG.ContentEncoder
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
extension SVG.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(_ tag:SVG.ContainerElement,
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
                self[tag, attributes] { $0 += value }
            }
        }
    }
}
