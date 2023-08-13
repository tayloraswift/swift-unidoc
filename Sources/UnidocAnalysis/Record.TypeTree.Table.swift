import BSONDecoding
import BSONEncoding
import FNV1
import UnidocRecords

extension Record.TypeTree
{
    /// A somewhat more-efficient representation for serializing an array of ``Row``s.
    @frozen @usableFromInline internal
    struct Table
    {
        @usableFromInline internal
        var rows:[Row]

        @inlinable internal
        init(rows:[Row])
        {
            self.rows = rows
        }
    }
}
extension Record.TypeTree.Table:BSONEncodable
{
    @usableFromInline internal
    func encode(to field:inout BSON.Field)
    {
        var buffer:[UInt8] = []
        for row:Record.TypeTree.Row in self.rows
        {
            row.shoot.serialize(into: &buffer)
            // We are kind of abusing these control characters here, but the point is that
            // they will never conflict with the UTF-8 encoding of a valid index node.
            buffer.append(row.top ?
                0x01 :  // Start-of-Heading
                0x02)   // Start-of-Text
        }

        BSON.BinaryView<[UInt8]>.init(subtype: .generic, slice: buffer).encode(to: &field)
    }
}
extension Record.TypeTree.Table:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable internal
    init<Bytes>(bson:BSON.BinaryView<Bytes>) throws
    {
        self.init(rows: [])

        var start:Bytes.Index = bson.slice.startIndex
        while   let end:Bytes.Index = bson.slice[start...].firstIndex(
                    where: { $0 == 0x01 || $0 == 0x02 })
        {
            let shoot:Record.Shoot = .deserialize(from: bson.slice[start ..< end])
            let top:Bool = bson.slice[end] == 0x01

            start = bson.slice.index(after: end)

            self.rows.append(.init(shoot: shoot, top: top))
        }
    }
}
