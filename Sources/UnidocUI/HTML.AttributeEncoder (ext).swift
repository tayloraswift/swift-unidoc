import HTML

extension HTML.AttributeEncoder
{
    var tooltip:Unidoc.TooltipMode?
    {
        get { nil }
        set (value)
        {
            self[data: "tooltip"] = value?.code
        }
    }

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
