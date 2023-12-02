import BSON
import JSON
import MD5
import SymbolGraphs
import Unidoc

@frozen public
struct SearchIndex<ID>:Identifiable, Sendable where ID:Hashable & Sendable
{
    public
    let id:ID
    /// The contents of the noun map, encoded as JSON. The server never parses it back; it
    /// is only ever sent to the client as opaque data.
    ///
    /// There are many things we could do to make this JSON smaller. But none of them would
    /// be as effective as applying a general text compression algorithm to the raw string.
    public
    let json:JSON

    @inlinable public
    init(id:ID, json:JSON)
    {
        self.id = id
        self.json = json
    }
}
extension SearchIndex<Never?>
{
    @inlinable public
    init(json:JSON)
    {
        self.init(id: nil, json: json)
    }
}
extension SearchIndex
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        /// Contains JSON, encoded as a UTF-8 string.
        case json = "J"
        /// Never decoded from the database.
        case hash = "H"
    }
}
extension SearchIndex:BSONDocumentEncodable, BSONEncodable
    where ID:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.json] = BSON.UTF8View<[UInt8]>.init(slice: self.json.utf8)
        bson[.hash] = MD5.init(hashing: self.json.utf8)
    }
}
extension SearchIndex:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
    where ID:BSONDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<CodingKey, Bytes>) throws
    {
        self.init(id: try bson[.id].decode(),
            json: try bson[.json].decode(as: BSON.UTF8View<Bytes.SubSequence>.self)
        {
            JSON.init(utf8: [UInt8].init($0.slice))
        })
    }
}
