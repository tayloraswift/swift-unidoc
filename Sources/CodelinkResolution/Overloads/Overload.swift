import Codelinks
import Symbols

@frozen public
struct Overload<Address>:Equatable, Hashable, Sendable
    where Address:Equatable & Hashable & Sendable
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
extension Overload
{
    @inlinable public
    init(target:__owned Target,
        phylum:__owned ScalarPhylum,
        id:__shared some CustomStringConvertible)
    {
        self.init(target: target, phylum: phylum, id: id.description)
    }
    public
    init(target:__owned Target,
        phylum:__owned ScalarPhylum,
        id:__shared String)
    {
        //  compute the id hash
        //  https://github.com/apple/swift-docc/blob/main/Sources/SwiftDocC/Utility/FoundationExtensions/String+Hashing.swift

        let full:UInt32 = id.utf8.reduce(2166136261) { ($0 &* 16777619) ^ .init($1) }
        let bits:UInt32 = (full >> 24) ^ (full & 0x00_ff_ff_ff)

        self.init(target: target, phylum: phylum, hash: .init(bits: bits))
    }
}
