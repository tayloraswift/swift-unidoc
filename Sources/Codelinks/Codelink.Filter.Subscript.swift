extension Codelink.Filter
{
    @frozen public
    enum Subscript:Equatable, Hashable, Sendable
    {
        /// Matches instance subscripts only.
        case  instance
        /// Matches class subscripts only.
        case `class`
        /// Matches static subscripts only.
        case `static`
        /// Matches static subscripts and class subscripts.
        case  type
    }
}
