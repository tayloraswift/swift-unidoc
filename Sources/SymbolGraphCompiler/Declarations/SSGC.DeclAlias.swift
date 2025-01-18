import LexicalPaths
import LinkResolution
import Symbols
import UCF

extension SSGC
{
    /// The bare minimum information needed to describe an aliased declaration.
    @frozen public
    struct DeclAlias
    {
        public
        let autograph:UCF.Autograph?
        public
        let phylum:Phylum.Decl
        public
        let kinks:Phylum.Decl.Kinks
        public
        let async:Bool
        public
        let path:UnqualifiedPath
        public
        let documented:Bool

        init(autograph:UCF.Autograph?,
            phylum:Phylum.Decl,
            kinks:Phylum.Decl.Kinks,
            async:Bool,
            path:UnqualifiedPath,
            documented:Bool)
        {
            self.autograph = autograph
            self.phylum = phylum
            self.kinks = kinks
            self.async = async
            self.path = path
            self.documented = documented
        }
    }
}
extension SSGC.DeclAlias
{
    init(from decl:borrowing SSGC.Decl)
    {
        self.init(
            autograph: decl.autograph,
            phylum: decl.phylum,
            kinks: decl.kinks,
            async: decl.async,
            path: decl.path,
            documented: decl.comment != nil)
    }
}
