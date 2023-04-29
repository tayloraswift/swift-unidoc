extension Compiler
{
    @usableFromInline @frozen internal
    struct ScalarNomination:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        let name:String
        @usableFromInline internal
        let phylum:ScalarPhylum

        init(_ name:String, phylum:ScalarPhylum)
        {
            self.name = name
            self.phylum = phylum
        }
    }
}
