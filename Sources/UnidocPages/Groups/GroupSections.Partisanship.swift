import ModuleGraphs

extension GroupSections
{
    enum Partisanship:Equatable, Hashable, Comparable, Sendable
    {
        case first
        case third(PackageIdentifier)
    }
}
