import BSONDecoding
import BSONEncoding
import FNV1

extension Volume.TypeTree
{
    /// A somewhat more-efficient representation for serializing an array of ``Row``s.
    @frozen @usableFromInline internal
    struct Table
    {
        @usableFromInline internal
        var rows:[Volume.Noun]

        @inlinable internal
        init(rows:[Volume.Noun])
        {
            self.rows = rows
        }
    }
}
extension Volume.TypeTree.Table:BSONEncodable
{
    @usableFromInline internal
    func encode(to field:inout BSON.Field)
    {
        var buffer:[UInt8] = []
        for row:Volume.Noun in self.rows
        {
            row.shoot.serialize(into: &buffer)
            // We are kind of abusing these control characters here, but the point is that
            // they will never conflict with the UTF-8 encoding of a valid index node.
            buffer.append(row.from.rawValue)
        }

        BSON.BinaryView<[UInt8]>.init(subtype: .generic, slice: buffer).encode(to: &field)
    }
}
extension Volume.TypeTree.Table:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable internal
    init<Bytes>(bson:BSON.BinaryView<Bytes>) throws
    {
        self.init(rows: [])

        var i:Bytes.Index = bson.slice.startIndex
        var j:Bytes.Index = i
        while j < bson.slice.endIndex
        {
            let next:Bytes.Index = bson.slice.index(after: j)
            if  let citizenship:Volume.Citizenship = .init(rawValue: bson.slice[j])
            {
                let shoot:Volume.Shoot = .deserialize(from: bson.slice[i ..< j])
                self.rows.append(.init(shoot: shoot, from: citizenship))

                i = next
                j = next
            }
            else
            {
                j = next
            }
        }
    }
}
