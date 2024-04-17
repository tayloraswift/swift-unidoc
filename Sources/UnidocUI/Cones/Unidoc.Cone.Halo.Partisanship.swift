import Symbols

extension Unidoc.Cone.Halo
{
    enum Partisanship:Equatable, Hashable, Comparable, Sendable
    {
        case first
        case third(Symbol.Package)
    }
}
