import Symbols

extension Swiftinit.Mesh.Halo
{
    enum Partisanship:Equatable, Hashable, Comparable, Sendable
    {
        case first
        case third(Symbol.Package)
    }
}
