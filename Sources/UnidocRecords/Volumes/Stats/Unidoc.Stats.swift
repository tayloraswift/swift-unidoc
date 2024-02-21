import BSON
import BSON_OrderedCollections
import OrderedCollections

extension Unidoc
{
    @frozen public
    struct Stats:Equatable, Sendable
    {
        /// External links, by domain.
        public
        var hyperlinks:OrderedDictionary<BSON.Key, Int>
        /// System programming interfaces.
        public
        var interfaces:OrderedDictionary<BSON.Key, Int>

        public
        var coverage:Coverage
        public
        var decls:Decl

        @inlinable public
        init(
            hyperlinks:OrderedDictionary<BSON.Key, Int> = [:],
            interfaces:OrderedDictionary<BSON.Key, Int> = [:],
            coverage:Coverage = .init(),
            decls:Decl = .init())
        {
            self.hyperlinks = hyperlinks
            self.interfaces = interfaces
            self.coverage = coverage
            self.decls = decls
        }
    }
}
extension Unidoc.Stats
{
    public
    enum CodingKey:String, Sendable
    {
        case hyperlinks = "H"
        case interfaces = "I"
        case coverage = "C"
        case decls = "D"
    }
}
extension Unidoc.Stats:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.hyperlinks] = self.hyperlinks.isEmpty ? nil : self.hyperlinks
        bson[.interfaces] = self.interfaces.isEmpty ? nil : self.interfaces
        bson[.coverage] = self.coverage
        bson[.decls] = self.decls
    }
}
extension Unidoc.Stats:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            hyperlinks: try bson[.hyperlinks]?.decode() ?? [:],
            interfaces: try bson[.interfaces]?.decode() ?? [:],
            coverage: try bson[.coverage].decode(),
            decls: try bson[.decls].decode())
    }
}
