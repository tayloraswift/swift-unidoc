import HTML
import Symbols
import UnidocRecords

extension Volume.Metadata.Subdomain
{
    enum Culture
    {
        case colonial(HTML.Link<Substring>, HTML.Link<Symbol.Module>)
        case original(HTML.Link<Substring>)
    }
}
