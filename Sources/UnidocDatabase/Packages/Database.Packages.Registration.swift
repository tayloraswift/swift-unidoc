import BSONDecoding
import BSONEncoding
import ModuleGraphs
import MongoSchema
import SymbolGraphs

extension Database.Packages
{
    struct Registration
    {
        let id:PackageIdentifier
        let cell:Int32

        init(id:PackageIdentifier, cell:Int32)
        {
            self.id = id
            self.cell = cell
        }
    }
}
extension Database.Packages.Registration:MongoMasterCodingModel
{
    enum CodingKey:String
    {
        case id = "_id"
        case cell = "P"
    }
}
extension Database.Packages.Registration:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.cell] = self.cell
    }
}
extension Database.Packages.Registration:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), cell: try bson[.cell].decode())
    }
}

