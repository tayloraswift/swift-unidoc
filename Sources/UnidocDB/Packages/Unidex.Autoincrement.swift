import BSON
import MongoQL
import UnidocRecords

extension Unidex
{
    enum Autoincrement<Document>:Sendable
        where   Document:Identifiable,
                Document:BSONDecodable,
                Document:Sendable,
                Document.ID:BSONDecodable,
                Document.ID:Sendable
    {
        case new(Document.ID)
        case old(Document.ID, Document?)
    }
}
extension Unidex.Autoincrement where Document.ID:ExpressibleByIntegerLiteral
{
    static
    var first:Self { .new(0) }
}
extension Unidex.Autoincrement:MongoMasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case document
    }
}
extension Unidex.Autoincrement:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let id:Document.ID = try bson[.id].decode()

        if  let document:[Document] = try bson[.document]?.decode()
        {
            self = .old(id, document.first)
        }
        else
        {
            self = .new(id)
        }
    }
}
