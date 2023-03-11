public
struct Declaration
{

}

extension Declaration
{
    @frozen public
    enum FragmentVisibility
    {
        /// The fragment will appear in an abridged signature, and
        /// will receive accented coloring, if available.
        case accented
        /// The fragment will appear in an abridged signature, but
        /// will not receive accented coloring.
        case always
        /// The fragment will not appear in an abridged signature.
        case elided
    }
}
