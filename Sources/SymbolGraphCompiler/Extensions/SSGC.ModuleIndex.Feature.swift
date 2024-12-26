import LexicalPaths
import LinkResolution
import Symbols
import UCF

extension SSGC.ModuleIndex
{
    /// The bare minimum information needed to describe an inherited feature.
    @frozen public
    struct Feature
    {
        public
        let phylum:Phylum.Decl
        public
        let path:UnqualifiedPath
        public
        let documented:Bool
        public
        let autograph:UCF.Autograph?

        init(phylum:Phylum.Decl,
            path:UnqualifiedPath,
            documented:Bool,
            autograph:UCF.Autograph?)
        {
            self.phylum = phylum
            self.path = path
            self.documented = documented
            self.autograph = autograph
        }
    }
}
extension SSGC.ModuleIndex.Feature
{
    init(from decl:borrowing SSGC.Decl)
    {
        self.init(phylum: decl.phylum,
            path: decl.path,
            documented: decl.comment != nil,
            autograph: decl.autograph)
    }
}
