import FNV1
import Symbols
import UCF

extension UCF
{
    @frozen public
    struct DisambiguationTraits
    {
        public
        let autograph:Autograph?
        public
        let phylum:Phylum.Decl
        public
        let kinks:Phylum.Decl.Kinks
        public
        let async:Bool
        public
        let hash:FNV24

        @inlinable public
        init(autograph:Autograph?,
            phylum:Phylum.Decl,
            kinks:Phylum.Decl.Kinks,
            async:Bool,
            hash:FNV24)
        {
            self.autograph = autograph
            self.phylum = phylum
            self.kinks = kinks
            self.async = async
            self.hash = hash
        }
    }
}
