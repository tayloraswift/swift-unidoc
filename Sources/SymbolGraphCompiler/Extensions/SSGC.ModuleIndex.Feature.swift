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

        init(phylum:Phylum.Decl, path:UnqualifiedPath)
        {
            self.phylum = phylum
            self.path = path
        }
    }
}
extension SSGC.ModuleIndex.Feature
{
    init(from decl:borrowing SSGC.Decl)
    {
        self.init(phylum: decl.phylum, path: decl.path)
    }
}
