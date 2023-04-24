import Symbolics

extension CodelinkResolver
{
    @frozen public
    struct Overload:Equatable, Hashable, Sendable
    {
        public
        let target:Target

        let phylum:ScalarPhylum
        let hash:Codelink.Hash

        private
        init(target:Target, phylum:ScalarPhylum, hash:Codelink.Hash)
        {
            self.target = target
            self.phylum = phylum
            self.hash = hash
        }
    }
}
extension CodelinkResolver.Overload
{
    public
    init(target:__owned CodelinkResolver.Target,
        phylum:__owned ScalarPhylum,
        id:__shared ScalarIdentifier)
    {
        //  compute the id hash
        //  https://github.com/apple/swift-docc/blob/main/Sources/SwiftDocC/Utility/FoundationExtensions/String+Hashing.swift

        let full:UInt32 = id.rawValue.utf8.reduce(2166136261) { ($0 &* 16777619) ^ .init($1) }
        let bits:UInt32 = (full >> 24) ^ (full & 0x00_ff_ff_ff)

        self.init(target: target, phylum: phylum, hash: .init(bits: bits))
    }
}
