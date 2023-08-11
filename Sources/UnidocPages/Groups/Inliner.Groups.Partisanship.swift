import ModuleGraphs
import Unidoc
import UnidocRecords

extension Inliner.Groups
{
    enum Partisanship:Equatable, Hashable, Comparable, Sendable
    {
        case first
        case third(PackageIdentifier)
    }
}
extension Inliner.Groups.Partisanship
{
    static
    func of(extension id:Unidoc.Scalar, zones:InlinerCache.Zones) -> Self?
    {
        if  id.zone == zones.principal.id
        {
            return .first
        }
        else if let zone:Record.Zone = zones[id.zone]
        {
            return .third(zone.package)
        }
        else
        {
            return nil
        }
    }
}
