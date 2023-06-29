import Unidoc

extension Record.Passage
{
    @frozen public
    enum Referent:Equatable, Sendable
    {
        case text(String)
        case path([Unidoc.Scalar])
    }
}
