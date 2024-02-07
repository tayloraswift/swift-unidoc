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
        let utf8:Content
        public
        let hash:MD5

        @inlinable public
        init(utf8:Content, hash:MD5)
        {
            self.utf8 = utf8
            self.hash = hash
        }
    }
}
extension Unidoc.TextResourceOutput:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case utf8 = "J"
        case hash = "H"
    }
}
extension Unidoc.TextResourceOutput:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let utf8:Content = try bson[.utf8].decode
        {
            if  case .string(let utf8) = $0
            {
                //  Do we really need to copy the bytes here?
                .binary([UInt8].init(utf8.bytes))
            }
            else
            {
                .length(try $0.cast { try $0.as(Int.self) })
            }
        }
        self.init(utf8: utf8, hash: try bson[.hash].decode())
    }
}
