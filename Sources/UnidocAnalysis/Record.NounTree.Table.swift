import BSONDecoding
import BSONEncoding
import FNV1
import UnidocRecords

extension Record.NounTree
{
    /// A somewhat more-efficient representation for serializing an array of ``Row``s.
    @frozen @usableFromInline internal
    struct Table
    {
        @usableFromInline internal
        var rows:[Record.Noun]

        @inlinable internal
        init(rows:[Record.Noun])
        {
            self.rows = rows
        }
    }
}
extension Record.NounTree.Table:BSONEncodable
{
    @usableFromInline internal
    func encode(to field:inout BSON.Field)
    {
        var buffer:[UInt8] = []
        for row:Record.Noun in self.rows
        {
            row.shoot.serialize(into: &buffer)
            // We are kind of abusing these control characters here, but the point is that
            // they will never conflict with the UTF-8 encoding of a valid index node.
            buffer.append(row.same?.rawValue ?? 0x03)
        }

        BSON.BinaryView<[UInt8]>.init(subtype: .generic, slice: buffer).encode(to: &field)
    }
}
extension Record.NounTree.Table:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable internal
    init<Bytes>(bson:BSON.BinaryView<Bytes>) throws
    {
        self.init(rows: [])

        var start:Bytes.Index = bson.slice.startIndex
        while   let end:Bytes.Index = bson.slice[start...].firstIndex(
                    where: { 0x01 ... 0x03 ~= $0 })
        {
            let shoot:Record.Shoot = .deserialize(from: bson.slice[start ..< end])
            let same:Record.Noun.Locality? = .init(rawValue: bson.slice[end])

            start = bson.slice.index(after: end)

            self.rows.append(.init(shoot: shoot, same: same))
        }
    }
}
