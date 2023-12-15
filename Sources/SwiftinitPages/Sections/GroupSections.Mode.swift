import Symbols

extension GroupSections
{
    enum Mode:Hashable, Equatable, Sendable
    {
        case decl(Phylum.Decl, Phylum.Decl.Kinks)
        case meta
    }
}
