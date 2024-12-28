import FNV1
import Symbols
import UCF

extension UCF
{
    @frozen public
    struct PackageOverload:ResolvableOverload, Sendable
    {
        public
        let phylum:Phylum.Decl
        public
        let decl:Int32
        public
        let heir:Int32?
        public
        let hash:FNV24

        public
        let documented:Bool
        public
        let autograph:Autograph?
        /// Used for display purposes. This is not necessarily the symbol from which the
        /// ``hash`` was computed.
        public
        let id:Symbol.Decl

        @inlinable public
        init(phylum:Phylum.Decl,
            decl:Int32,
            heir:Int32?,
            hash:FNV24,
            documented:Bool,
            autograph:Autograph?,
            id:Symbol.Decl)
        {
            self.phylum = phylum
            self.decl = decl
            self.heir = heir
            self.hash = hash
            self.documented = documented
            self.autograph = autograph
            self.id = id
        }
    }
}
