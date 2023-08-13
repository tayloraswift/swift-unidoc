import BSONDecoding
import BSONEncoding
import FNV1
import UnidocRecords

extension Records.TypeTree
{
    @frozen public
    struct Top
    {
        public
        let stem:Record.Stem
        public
        let hash:FNV24?
        public
        var nest:[Node]

        @inlinable public
        init(stem:Record.Stem, hash:FNV24? = nil, nest:[Node] = [])
        {
            self.stem = stem
            self.hash = hash
            self.nest = nest
        }
    }
}
extension Records.TypeTree.Top
{
    static
    func += (self:inout Self, nodes:[Records.TypeLevels.Node])
    {
        for node:Records.TypeLevels.Node in nodes
        {
            self.nest.append(.init(stem: node.stem, hash: node.hash))
            self += node.nest
        }
    }
}
extension Records.TypeTree.Top
{
    var node:Records.TypeTree.Node
    {
        .init(stem: self.stem, hash: self.hash)
    }
}
extension Records.TypeTree.Top:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        var buffer:[UInt8] = []
        for node:Records.TypeTree.Node in self.nest
        {
            node.serialize(into: &buffer)
            buffer.append(0x0A)
        }

        self.node.serialize(into: &buffer)

        BSON.BinaryView<[UInt8]>.init(subtype: .generic, slice: buffer).encode(to: &field)
    }
}
extension Records.TypeTree.Top:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.BinaryView<Bytes>) throws
    {
        var nodes:[Records.TypeTree.Node] = []

        var start:Bytes.Index = bson.slice.startIndex
        while let end:Bytes.Index = bson.slice[start...].firstIndex(of: 0x0A)
        {
            nodes.append(.deserialize(bson.slice[start ..< end]))
            start = bson.slice.index(after: end)
        }

        let top:Records.TypeTree.Node = .deserialize(bson.slice[start...])

        self.init(stem: top.stem, hash: top.hash, nest: nodes)
    }
}
