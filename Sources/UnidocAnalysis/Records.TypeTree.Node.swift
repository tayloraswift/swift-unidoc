import FNV1
import UnidocRecords

extension Records.TypeTree
{
    @frozen public
    struct Node
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
extension Records.TypeTree.Node
{
    @inlinable internal static
    func deserialize<Bytes>(_ bytes:Bytes) -> Self where Bytes:RandomAccessCollection<UInt8>
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

    func serialize(into buffer:inout [UInt8])
    {
        buffer += self.stem.rawValue.utf8
        if  let hash:FNV24 = self.hash
        {
            buffer.append(0x00)
            buffer += hash.description.utf8
        }
    }

    func description(_ indent:String = "    ") -> String
    {
        let indent:String = .init(repeating: indent, count: max(0, self.stem.depth - 1))
        return "\(indent)\(self.stem.last)"
    }
}
