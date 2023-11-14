extension XML.Sitemap.ContentEncoder
{
    @inlinable public
    subscript<Renderable>(_ tag:XML.Sitemap.Element) -> Renderable?
        where Renderable:StringProtocol
    {
        get
        {
            nil
        }
        set(value)
        {
            if  let value:Renderable
            {
                self[tag] { $0 += value }
            }
        }
    }
}
