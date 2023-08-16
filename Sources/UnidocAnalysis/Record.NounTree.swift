import BSONDecoding
import BSONEncoding
import Unidoc
import UnidocRecords

extension Record
{
    @available(*, deprecated, renamed: "NounTree")
    public
    typealias TypeTree = NounTree
}
extension Record
{
    @frozen public
    struct NounTree:Identifiable, Equatable, Sendable
    {
        public
        let id:Unidoc.Scalar
        public
        var rows:[Row]

        @inlinable public
        init(id:Unidoc.Scalar, rows:[Row] = [])
        {
            self.id = id
            self.rows = rows
        }
    }
}
extension Record.NounTree
{
    init(id:Unidoc.Scalar, top:[Records.TypeLevels.Node])
    {
        self.init(id: id)

        for top:Records.TypeLevels.Node in top
        {
            self.rows.append(.init(shoot: top.shoot, top: true))
            self += top.nest
        }
    }

    static
    func += (self:inout Self, nodes:[Records.TypeLevels.Node])
    {
        for node:Records.TypeLevels.Node in nodes
        {
            self.rows.append(.init(shoot: node.shoot, top: false))
            self += node.nest
        }
    }
}
extension Record.NounTree
{
    @inlinable internal
    init(id:Unidoc.Scalar, table:Table)
    {
        self.init(id: id, rows: table.rows)
    }

    var table:Table { .init(rows: self.rows) }
}
extension Record.NounTree
{
    public
    enum CodingKey:String
    {
        case id = "_id"
        case table = "T"
    }
}
extension Record.NounTree:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.table] = self.table
    }
}
extension Record.NounTree:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), table: try bson[.table].decode())
    }
}
extension Record.NounTree:CustomStringConvertible
{
    public
    var description:String
    {
        var description:String = ""
        for row:Row in self.rows
        {
            if  row.top
            {
                description += "\(row.shoot.stem.name)\n"
            }
            else
            {
                description += "\(row.shoot.description())\n"
            }
        }
        return description
    }
}
