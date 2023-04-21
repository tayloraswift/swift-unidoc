import SymbolGraphs

extension CodelinkResolver
{
    @frozen public
    struct Overload:Equatable, Hashable, Sendable
    {
        public
        let target:Target

        let phylum:SymbolGraph.Scalar.Phylum
        let hash:Codelink.Hash

        private
        init(target:Target, phylum:SymbolGraph.Scalar.Phylum, hash:Codelink.Hash)
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
    init(target:CodelinkResolver.Target,
        phylum:SymbolGraph.Scalar.Phylum,
        id:__shared String)
    {
        //  compute the id hash
        //  https://github.com/apple/swift-docc/blob/main/Sources/SwiftDocC/Utility/FoundationExtensions/String+Hashing.swift

        let full:UInt32 = id.utf8.reduce(2166136261) { ($0 &* 16777619) ^ .init($1) }
        let bits:UInt32 = (full >> 24) ^ (full & 0x00_ff_ff_ff)

        self.init(target: target, phylum: phylum, hash: .init(bits: bits))
    }
}
