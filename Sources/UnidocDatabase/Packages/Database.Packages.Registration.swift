import ModuleGraphs
import SymbolGraphs
import BSONDecoding
import BSONEncoding

extension Database.Packages
{
    struct Registration
    {
        let id:PackageIdentifier
        let address:Int32

        init(id:PackageIdentifier, address:Int32)
        {
            self.id = id
            self.address = address
        }
    }
}
extension Database.Packages.Registration
{
    enum CodingKeys:String
    {
        case id = "_id"
        case address = "P"
    }

    static
    subscript(key:CodingKeys) -> BSON.Key { .init(key) }
}
extension Database.Packages.Registration:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.id
        bson[.address] = self.address
    }
}
extension Database.Packages.Registration:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(), address: try bson[.address].decode())
    }
}

