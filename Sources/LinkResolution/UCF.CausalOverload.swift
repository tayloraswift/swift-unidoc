import FNV1
import Symbols
import UCF

extension UCF
{
    @frozen public
    struct CausalOverload:ResolvableOverload, Sendable
    {
        public
        let phylum:Phylum.Decl
        public
        let decl:Symbol.Decl
        public
        let heir:Symbol.Decl?
        public
        let hash:FNV24

        public
        let documented:Bool

        @inlinable public
        init(phylum:Phylum.Decl,
            decl:Symbol.Decl,
            heir:Symbol.Decl?,
            hash:FNV24,
            documented:Bool)
        {
            self.phylum = phylum
            self.decl = decl
            self.heir = heir
            self.hash = hash
            self.documented = documented
        }
    }
}
extension UCF.CausalOverload:Identifiable
{
    @inlinable public
    var id:Symbol.Decl { self.decl }
}
