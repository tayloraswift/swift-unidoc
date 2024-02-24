import Symbols
import Unidoc

extension SSGC
{
    @usableFromInline @frozen internal
    struct Nomination:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        let name:String
        @usableFromInline internal
        let phylum:Phylum.Decl

        init(_ name:String, phylum:Phylum.Decl)
        {
            self.name = name
            self.phylum = phylum
        }
    }
}
