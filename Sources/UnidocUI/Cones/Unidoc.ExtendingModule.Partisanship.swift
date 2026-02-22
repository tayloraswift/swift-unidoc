import Symbols

extension Unidoc.ExtendingModule {
    enum Partisanship: Equatable, Hashable, Comparable {
        case first
        case third(Symbol.Package)
    }
}
