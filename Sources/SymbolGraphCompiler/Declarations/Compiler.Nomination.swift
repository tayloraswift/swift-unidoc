import Symbols
import Unidoc

extension Compiler
{
    @usableFromInline @frozen internal
    struct Nomination:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        let name:String
        @usableFromInline internal
        let phylum:Unidoc.Decl

        init(_ name:String, phylum:Unidoc.Decl)
        {
            self.name = name
            self.phylum = phylum
        }
    }
}
