import Unidoc

extension GroupSections
{
    enum Mode:Hashable, Equatable, Sendable
    {
        case decl(Unidoc.Decl, Unidoc.Decl.Kinks)
        case meta
    }
}
