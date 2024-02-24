import BSON
import BSON_OrderedCollections
import OrderedCollections

extension Unidoc
{
    @frozen public
    struct Stats:Equatable, Sendable
    {
        public
        var coverage:Coverage
        public
        var decls:Decl

        @inlinable public
        init(coverage:Coverage = .init(), decls:Decl = .init())
        {
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
        case coverage = "C"
        case decls = "D"
    }
}
extension Unidoc.Stats:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.coverage] = self.coverage
        bson[.decls] = self.decls
    }
}
extension Unidoc.Stats:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(coverage: try bson[.coverage].decode(), decls: try bson[.decls].decode())
    }
}
