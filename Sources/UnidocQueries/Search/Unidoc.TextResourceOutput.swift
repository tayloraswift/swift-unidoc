import BSON
import MD5
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct TextResourceOutput:Sendable
    {
        public
        let text:Content
        public
        let hash:MD5

        @inlinable public
        init(text:Content, hash:MD5)
        {
            self.text = text
            self.hash = hash
        }
    }
}
extension Unidoc.TextResourceOutput:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case text
        case hash
    }
}
extension Unidoc.TextResourceOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let text:Content = try bson[.text].decode
        {
            if  case .binary(let gzip) = $0
            {
                .inline(.gzip(gzip.bytes))
            }
            else if
                case .string(let utf8) = $0
            {
                //  Do we really need to copy the bytes here?
                .inline(.utf8(utf8.bytes))
            }
            else
            {
                .length(try $0.cast { try $0.as(Int.self) })
            }
        }
        self.init(text: text, hash: try bson[.hash].decode())
    }
}
