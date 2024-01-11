import Symbols

extension Swiftinit.GroupLists
{
    enum Partisanship:Equatable, Hashable, Comparable, Sendable
    {
        case first
        case third(Symbol.Package)
    }
}
