extension XML.Sitemap
{
    @frozen public
    struct AttributeEncoder:StreamingEncoder
    {
        @usableFromInline internal
        var utf8:[UInt8]

        @inlinable internal
        init(utf8:[UInt8] = [])
        {
            self.utf8 = utf8
        }
    }
}
extension XML.Sitemap.AttributeEncoder
{
    @inlinable public
    var xmlns:String?
    {
        get
        {
            nil
        }
        set(text)
        {
            if  let text:String
            {
                self.utf8 += DOM.Property<XMLNS>.init(.xmlns, text)
            }
        }
    }
}
