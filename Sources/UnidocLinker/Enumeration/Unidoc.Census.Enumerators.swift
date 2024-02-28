import SymbolGraphs

extension Unidoc.Census
{
    struct Enumerators
    {
        private(set)
        var cultures:[Enumerator]
        private(set)
        var combined:Enumerator

        init(cultures:Int)
        {
            self.cultures = .init(repeating: .init(), count: cultures)
            self.combined = .init()
        }
    }
}
extension Unidoc.Census.Enumerators
{
    mutating
    func count(
        citizen decl:SymbolGraph.Decl,
        culture:Int,
        _from snapshot:Unidoc.Linker.Graph,
        _at local:Int32)
    {
        let interface:Unidoc.Census.Interface
        if  decl.route.underscored
        {
            interface = .underscored
        }
        else if case nil = decl.signature.spis
        {
            interface = .unrestricted
        }
        else
        {
            //  Don’t have a way to get the SPI names yet.
            interface = .spi(nil)
        }

        self.cultures[culture].interfaces[interface, default: 0] += 1
        self.combined.interfaces[interface, default: 0] += 1

        let coverage:WritableKeyPath<Unidoc.Stats.Coverage, Int> = .classify(decl,
            _from: snapshot,
            _at: local)

        self.cultures[culture].coverage[keyPath: coverage] += 1
        self.combined.coverage[keyPath: coverage] += 1

        let phylum:WritableKeyPath<Unidoc.Stats.Decl, Int> = .classify(decl)

        self.cultures[culture].phyla[keyPath: phylum] += 1
        self.combined.phyla[keyPath: phylum] += 1
    }

    mutating
    func count(feature decl:SymbolGraph.Decl, culture:Int)
    {
        let phylum:WritableKeyPath<Unidoc.Stats.Decl, Int> = .classify(decl)

        self.cultures[culture].phylaInherited[keyPath: phylum] += 1
        self.combined.phylaInherited[keyPath: phylum] += 1
    }
}
