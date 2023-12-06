import BSON
import MongoQL
import SHA1
import Unidoc
import UnidocRecords

extension Realm
{
    enum EditionPlacement
    {
        case new(Unidoc.Version)
        case old(Edition)
    }
}
extension Realm.EditionPlacement
{
    static
    var first:Self { .new(0) }
}
extension Realm.EditionPlacement:MongoMasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case coordinate
        case edition
    }
}
extension Realm.EditionPlacement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        if  let edition:Realm.Edition = try bson[.edition]?.decode()
        {
            self = .old(edition)
        }
        else
        {
            self = .new(try bson[.coordinate].decode())
        }
    }
}
