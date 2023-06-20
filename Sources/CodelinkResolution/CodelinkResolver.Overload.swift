import FNV1
import Symbols

extension CodelinkResolver
{
    @frozen public
    struct Overload:Equatable, Hashable
    {
        public
        let target:Target

        public
        let phylum:ScalarPhylum
        public
        let hash:FNV24

        @inlinable public
        init(target:Target, phylum:ScalarPhylum, hash:FNV24)
        {
            self.target = target
            self.phylum = phylum
            self.hash = hash
        }
    }
}
extension CodelinkResolver.Overload:Sendable where Address:Sendable
{
}
