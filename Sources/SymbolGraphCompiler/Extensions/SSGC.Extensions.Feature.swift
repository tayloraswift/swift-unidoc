import Symbols

extension SSGC.ModuleIndex
{
    /// The bare minimum information needed to describe an inherited feature.
    @frozen public
    struct Feature
    {
        public
        let lastName:String
        public
        let phylum:Phylum.Decl

        init(lastName:String, phylum:Phylum.Decl)
        {
            self.lastName = lastName
            self.phylum = phylum
        }
    }
}
extension SSGC.ModuleIndex.Feature
{
    init(from decl:borrowing SSGC.Decl)
    {
        self.init(lastName: decl.path.last, phylum: decl.phylum)
    }
}
