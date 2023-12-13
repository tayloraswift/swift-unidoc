import BSON
import MongoQL
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct Alias<Symbol, Target>:Identifiable, Equatable, Sendable
        where   Symbol:Hashable,
                Symbol:Sendable,
                Symbol:BSONDecodable,
                Symbol:BSONEncodable,
                Target:Identifiable,
                Target.ID:Sendable,
                Target.ID:BSONDecodable,
                Target.ID:BSONEncodable
    {
        public
        let id:Symbol

        public
        let coordinate:Target.ID

        @inlinable public
        init(id:Symbol, coordinate:Target.ID)
        {
            self.id = id
            self.coordinate = coordinate
        }
    }
}
extension Unidoc
{
    @frozen public
    enum AliasKey:String, Sendable
    {
        case id = "_id"
        case coordinate = "p"
    }
}
extension Unidoc.Alias:MongoMasterCodingModel
{
    public
    typealias CodingKey = Unidoc.AliasKey
}
extension Unidoc.Alias:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.coordinate] = self.coordinate
    }
}
extension Unidoc.Alias:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), coordinate: try bson[.coordinate].decode())
    }
}
