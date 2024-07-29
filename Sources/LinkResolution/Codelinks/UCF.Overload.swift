import UCF
import FNV1
import Symbols

extension UCF
{
    @frozen public
    struct Overload<Scalar>:Equatable, Hashable where Scalar:Hashable
    {
        public
        let target:Target

        /// The phylum of the target, if it is a declaration. If a module, this is nil.
        public
        let phylum:Phylum.Decl?
        public
        let hash:FNV24

        @inlinable public
        init(target:Target, phylum:Phylum.Decl?, hash:FNV24)
        {
            self.target = target
            self.phylum = phylum
            self.hash = hash
        }
    }
}
extension UCF.Overload:Sendable where Scalar:Sendable
{
}
