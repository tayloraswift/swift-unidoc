import BSON
import JSON
import MD5
import SymbolGraphs
import Unidoc

@available(*, deprecated, renamed: "Unidoc.TextResource")
public
typealias SearchIndex = Unidoc.TextResource

extension Unidoc
{
    @frozen public
    struct TextResource<ID>:Identifiable, Sendable where ID:Hashable & Sendable
    {
        public
        let id:ID
        /// The raw UTF8 data. The server never parses it back; it is only ever sent to the
        /// client as opaque data.
        ///
        /// There are many things we could do to make this JSON smaller. But none of them would
        /// be as effective as applying a general text compression algorithm to the raw string.
        public
        let utf8:[UInt8]

        @inlinable public
        init(id:ID, utf8:[UInt8])
        {
            self.id = id
            self.utf8 = utf8
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
        bson[.utf8] = BSON.UTF8View<[UInt8]>.init(slice: self.utf8)
        bson[.hash] = MD5.init(hashing: self.utf8)
    }
}
extension Unidoc.TextResource:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
    where ID:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKey, Bytes>) throws
    {
        self.init(id: try bson[.id].decode(),
            utf8: try bson[.utf8].decode(as: BSON.UTF8View<Bytes.SubSequence>.self)
        {
            [UInt8].init($0.slice)
        })
    }
}
