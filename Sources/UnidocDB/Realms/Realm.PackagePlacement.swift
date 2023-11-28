import BSONDecoding
import BSONEncoding
import MongoQL
import UnidocRecords

extension Realm
{
    enum PackagePlacement
    {
        case new(Int32)
        case old(Int32, Package?)
    }
}
extension Realm.PackagePlacement
{
    static
    var first:Self { .new(0) }
}
extension Realm.PackagePlacement:MongoMasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case coordinate
        case package
    }
}
extension Realm.PackagePlacement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let coordinate:Int32 = try bson[.coordinate].decode()

        if  let package:[Realm.Package] = try bson[.package]?.decode()
        {
            self = .old(coordinate, package.first)
        }
        else
        {
            self = .new(coordinate)
        }
    }
}
