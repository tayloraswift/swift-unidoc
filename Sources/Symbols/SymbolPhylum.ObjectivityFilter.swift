extension SymbolPhylum
{
    @frozen public
    enum ObjectivityFilter:Equatable, Hashable, Sendable
    {
        /// Matches global symbols and instance members.
        case `default`
        /// Matches instance members only.
        case  instance
        /// Matches class members only.
        case `class`
        /// Matches static members only.
        case `static`
        /// Matches global members only.
        case  global
        /// Matches static members and class members.
        case  type
    }
}
