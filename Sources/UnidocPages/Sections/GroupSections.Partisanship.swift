import Symbols

extension GroupSections
{
    enum Partisanship:Equatable, Hashable, Comparable, Sendable
    {
        case first
        case third(Symbol.Package)
    }
}
