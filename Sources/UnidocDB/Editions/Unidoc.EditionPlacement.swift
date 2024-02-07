import BSON
import MongoQL
import SHA1
import Unidoc
import UnidocRecords

extension Unidoc
{
    enum EditionPlacement
    {
        case new(Unidoc.Version)
        case old(Unidoc.EditionMetadata)
    }
}
extension Unidoc.EditionPlacement
{
    static
    var first:Self { .new(0) }
}
extension Unidoc.EditionPlacement:MongoMasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case coordinate
        case edition
    }
}
extension Unidoc.EditionPlacement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
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
