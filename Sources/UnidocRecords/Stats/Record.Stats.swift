import BSONDecoding
import BSONEncoding

extension Record
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
extension Record.Stats
{
    public
    enum CodingKey:String
    {
        case coverage = "C"
        case decls = "D"
    }
}
extension Record.Stats:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.coverage] = self.coverage
        bson[.decls] = self.decls
    }
}
extension Record.Stats:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            coverage: try bson[.coverage].decode(),
            decls: try bson[.decls].decode())
    }
}
