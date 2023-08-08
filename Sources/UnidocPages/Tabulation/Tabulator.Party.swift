import ModuleGraphs

extension Tabulator
{
    enum Party:Equatable, Hashable, Comparable, Sendable
    {
        case first
        case third(PackageIdentifier)
    }
}
