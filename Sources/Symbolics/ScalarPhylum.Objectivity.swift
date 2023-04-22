extension ScalarPhylum
{
    @frozen public
    enum Objectivity:Equatable, Hashable, Comparable, Sendable
    {
        case instance
        case `class`
        case `static`
    }
}
