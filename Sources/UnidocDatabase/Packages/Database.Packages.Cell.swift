import BSONDecoding
import BSONEncoding
import ModuleGraphs
import MongoQL

extension Database.Packages
{
    struct Cell
    {
        let id:PackageIdentifier
        let index:Int32

        init(id:PackageIdentifier, index:Int32)
        {
            self.id = id
            self.index = index
        }
    }
}
extension Database.Packages.Cell:MongoMasterCodingModel
{
    enum CodingKey:String
    {
        case id = "_id"
        case index = "P"
    }
}
extension Database.Packages.Cell:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.index] = self.index
    }
}
extension Database.Packages.Cell:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), index: try bson[.index].decode())
    }
}

