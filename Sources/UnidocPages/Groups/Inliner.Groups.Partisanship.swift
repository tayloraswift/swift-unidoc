import ModuleGraphs
import Unidoc
import UnidocRecords

extension Inliner.Groups
{
    enum Partisanship:Equatable, Hashable, Comparable, Sendable
    {
        case first(Int32)
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
            /// Module numbers are lexicographically ordered according to the package’s
            /// internal dependency graph, so the library with the lowest module number
            /// will always be the current culture, if it is present.
            return .first(id.citizen)
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
