extension Unidoc.Noun
{
    @frozen public
    enum Style:Equatable, Hashable, Comparable, Sendable
    {
        case stem(Unidoc.Citizenship)
        /// Custom text, used to display article titles instead of their stems.
        case text(String)
    }
}
