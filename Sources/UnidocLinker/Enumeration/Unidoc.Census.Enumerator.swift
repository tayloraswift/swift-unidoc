extension Unidoc.Census
{
    struct Enumerator
    {
        var interfaces:[Interface: Int]
        var coverage:Unidoc.Stats.Coverage
        var phyla:Unidoc.Stats.Decl
        var phylaInherited:Unidoc.Stats.Decl

        init()
        {
            self.interfaces = [:]
            self.coverage = [:]
            self.phyla = [:]
            self.phylaInherited = [:]
        }
    }
}
