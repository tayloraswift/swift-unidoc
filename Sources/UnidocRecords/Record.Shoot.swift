import FNV1

extension Record
{
    @frozen public
    struct Shoot:Equatable, Hashable, Sendable
    {
        public
        let stem:Record.Stem
        public
        let hash:FNV24?

        @inlinable public
        init(stem:Record.Stem, hash:FNV24? = nil)
        {
            self.stem = stem
            self.hash = hash
        }
    }
}
extension Record.Shoot:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.stem, lhs.hash?.value ?? 0) < (rhs.stem, rhs.hash?.value ?? 0)
    }
}
extension Record.Shoot
{
    @inlinable public static
    func deserialize<Bytes>(from bytes:Bytes) -> Self where Bytes:RandomAccessCollection<UInt8>
    {
        let stem:Record.Stem
        let hash:FNV24?
        if  let question:Bytes.Index = bytes.lastIndex(of: 0x00)
        {
            stem = .init(rawValue: .init(
                decoding: bytes[..<question],
                as: Unicode.UTF8.self))

            hash = .init(String.init(
                decoding: bytes[bytes.index(after: question)...],
                as: Unicode.ASCII.self))
        }
        else
        {
            stem = .init(rawValue: .init(decoding: bytes, as: Unicode.UTF8.self))
            hash = nil
        }

        return .init(stem: stem, hash: hash)
    }

    @inlinable public
    func serialize(into buffer:inout [UInt8])
    {
        buffer += self.stem.rawValue.utf8
        if  let hash:FNV24 = self.hash
        {
            buffer.append(0x00)
            buffer += hash.description.utf8
        }
    }
}
extension Record.Shoot:CustomDebugStringConvertible
{
    public
    var debugDescription:String
    {
        self.hash.map
        {
            "\"\(self.stem)\" [\($0)]"
        } ?? "\"\(self.stem)\""
    }
}
