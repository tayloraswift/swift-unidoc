import LexicalPaths
import Symbols

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

        init(phylum:Phylum.Decl, path:UnqualifiedPath, documented:Bool)
        {
            self.phylum = phylum
            self.path = path
            self.documented = documented
        }
    }
}
extension SSGC.ModuleIndex.Feature
{
    init(from decl:borrowing SSGC.Decl)
    {
        self.init(phylum: decl.phylum, path: decl.path, documented: decl.comment != nil)
    }
}
