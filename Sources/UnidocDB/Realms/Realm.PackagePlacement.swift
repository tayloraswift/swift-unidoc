import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Realm
{
    enum PackagePlacement
    {
        case new(Unidoc.Package)
        case old(Unidoc.Package, Package?)
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
        let coordinate:Unidoc.Package = try bson[.coordinate].decode()

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
