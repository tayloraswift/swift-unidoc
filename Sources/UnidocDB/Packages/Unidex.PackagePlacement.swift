import BSON
import MongoQL
import Unidoc
import UnidocRecords

extension Unidex
{
    enum PackagePlacement
    {
        case new(Unidoc.Package)
        case old(Unidoc.Package, Package?)
    }
}
extension Unidex.PackagePlacement
{
    static
    var first:Self { .new(0) }
}
extension Unidex.PackagePlacement:MongoMasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case coordinate
        case package
    }
}
extension Unidex.PackagePlacement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let coordinate:Unidoc.Package = try bson[.coordinate].decode()

        if  let package:[Unidex.Package] = try bson[.package]?.decode()
        {
            self = .old(coordinate, package.first)
        }
        else
        {
            self = .new(coordinate)
        }
    }
}
