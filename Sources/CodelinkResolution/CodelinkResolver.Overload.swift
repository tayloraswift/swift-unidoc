import FNV1
import Unidoc

extension CodelinkResolver
{
    @frozen public
    struct Overload:Equatable, Hashable
    {
        public
        let target:Target

        public
        let phylum:Unidoc.Decl
        public
        let hash:FNV24

        @inlinable public
        init(target:Target, phylum:Unidoc.Decl, hash:FNV24)
        {
            self.target = target
            self.phylum = phylum
            self.hash = hash
        }
    }
}
extension CodelinkResolver.Overload:Sendable where Scalar:Sendable
{
}
