import BSON
import MongoQL
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Realm
{
    @frozen public
    struct PackageAlias:Identifiable, Equatable, Sendable
    {
        public
        let id:Symbol.Package
        public
        let coordinate:Unidoc.Package

        @inlinable public
        init(id:Symbol.Package, coordinate:Unidoc.Package)
        {
            self.id = id
            self.coordinate = coordinate
        }
    }
}
extension Realm.PackageAlias:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case coordinate = "p"
    }
}
extension Realm.PackageAlias:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.coordinate] = self.coordinate
    }
}
extension Realm.PackageAlias:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), coordinate: try bson[.coordinate].decode())
    }
}
