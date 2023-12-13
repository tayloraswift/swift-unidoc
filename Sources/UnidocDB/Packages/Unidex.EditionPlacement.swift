import BSON
import MongoQL
import SHA1
import Unidoc
import UnidocRecords

extension Unidex
{
    enum EditionPlacement
    {
        case new(Unidoc.Version)
        case old(Edition)
    }
}
extension Unidex.EditionPlacement
{
    static
    var first:Self { .new(0) }
}
extension Unidex.EditionPlacement:MongoMasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case coordinate
        case edition
    }
}
extension Unidex.EditionPlacement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        if  let edition:Unidoc.EditionMetadata = try bson[.edition]?.decode()
        {
            self = .old(edition)
        }
        else
        {
            self = .new(try bson[.coordinate].decode())
        }
    }
}
