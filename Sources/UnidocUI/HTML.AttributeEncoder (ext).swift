import HTML

extension HTML.AttributeEncoder
{
    @inlinable mutating
    func external(safe:Bool)
    {
        self.target = "_blank"

        if  safe
        {
            self.rel = .external
        }
        else
        {
            self[name: .rel] = """
            \(HTML.Attribute.Rel.external) \
            \(HTML.Attribute.Rel.nofollow) \
            \(HTML.Attribute.Rel.noopener) \
            \(HTML.Attribute.Rel.google_ugc)
            """
        }
    }
}
