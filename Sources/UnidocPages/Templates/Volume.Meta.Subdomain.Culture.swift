import HTML
import UnidocRecords
import ModuleGraphs

extension Volume.Meta.Subdomain
{
    enum Culture
    {
        case colonial(HTML.Link<Substring>, HTML.Link<ModuleIdentifier>)
        case original(HTML.Link<Substring>)
    }
}
