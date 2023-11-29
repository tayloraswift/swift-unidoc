import BSONDecoding
import MD5
import UnidocDB
import UnidocRecords

extension SearchIndexQuery
{
    @frozen public
    struct Output:Sendable
    {
        public
        let json:Content
        public
        let hash:MD5

        @inlinable public
        init(json:Content, hash:MD5)
        {
            self.json = json
            self.hash = hash
        }
    }
}
extension SearchIndexQuery.Output:BSONDocumentDecodable
{
    public
    typealias CodingKey = SearchIndex<CollectionOrigin.Element.ID>.CodingKey

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        let json:Content = try bson[.json].decode
        {
            if  case .string(let utf8) = $0
            {
                return .binary([UInt8].init(utf8.slice))
            }
            else
            {
                return .length(try $0.cast { try $0.as(Int.self) })
            }
        }
        self.init(json: json, hash: try bson[.hash].decode())
    }
}
