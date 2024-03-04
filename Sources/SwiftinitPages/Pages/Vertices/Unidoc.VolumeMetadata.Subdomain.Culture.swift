import HTML
import Symbols
import UnidocRecords

extension Unidoc.VolumeMetadata.Subdomain
{
    enum Culture
    {
        case colonial(HTML.Link<Substring>, HTML.Link<Symbol.Module>)
        case original(HTML.Link<Substring>)
    }
}
