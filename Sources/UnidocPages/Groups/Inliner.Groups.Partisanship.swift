import ModuleGraphs

extension Inliner.Groups
{
    enum Partisanship:Equatable, Hashable, Comparable, Sendable
    {
        case first
        case third(PackageIdentifier)
    }
}
