import HTML
import UnidocRender

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

    @inlinable
    var link:Unidoc.LinkTarget?
    {
        get { nil }
        set (value)
        {
            guard
            let value:Unidoc.LinkTarget
            else
            {
                return
            }

            self.href = value.url ?? "."

            if  case .exported = value
            {
                self.external(safe: true)
            }
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
