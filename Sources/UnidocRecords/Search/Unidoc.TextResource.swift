import BSON
import JSON
import MD5
import SymbolGraphs
import Unidoc

extension Unidoc
{
    @frozen public
    struct TextResource<ID>:Identifiable, Sendable where ID:Hashable & Sendable
    {
        public
        let id:ID
        /// The raw UTF8 data. The server never parses it back; it is only ever sent to the
        /// client as opaque data.
        public
        let text:TextStorage

        @inlinable public
        init(id:ID, text:TextStorage)
        {
            self.id = id
            self.text = text
        }
    }
}
extension Unidoc.TextResource
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        /// Contains a UTF-8 string.
        case utf8 = "J"
        /// Contains a UTF-8 string, compressed with the LZ77 DEFLATE algorithm, and wrapped
        /// in a gzip container.
        case gzip = "Z"
        /// Never decoded from the database.
        case hash = "H"
    }
}
extension Unidoc.TextResource:BSONDocumentEncodable, BSONEncodable
    where ID:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        switch self.text
        {
        case .utf8(let utf8):
            bson[.hash] = MD5.init(hashing: utf8)
            bson[.utf8] = BSON.UTF8View<ArraySlice<UInt8>>.init(bytes: utf8)

        case .gzip(let gzip):
            bson[.hash] = MD5.init(hashing: gzip.bytes)
            bson[.gzip] = gzip
        }
    }
}
extension Unidoc.TextResource:BSONDocumentDecodable, BSONDecodable
    where ID:BSONDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let text:Unidoc.TextStorage
        if  let compressed:Unidoc.TextStorage.Compressed = try bson[.gzip]?.decode()
        {
            text = .gzip(compressed)
        }
        else
        {
            let utf8:BSON.UTF8View<ArraySlice<UInt8>> = try bson[.utf8].decode()
            text = .utf8(utf8.bytes)
        }

        self.init(id: try bson[.id].decode(), text: text)
    }
}
