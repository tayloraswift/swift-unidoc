import BSONDecoding
import BSONEncoding
import MarkdownABI

extension SymbolGraph
{
    @frozen public
    struct Article<ID>:Equatable, Sendable where ID:Equatable & Sendable
    {
        public
        var referents:[Referent]
        public
        var overview:MarkdownBytecode
        public
        var details:MarkdownBytecode
        /// The number of referents used by the overview paragraph alone.
        public
        var fold:Int

        public
        let id:ID?

        @inlinable public
        init(referents:[Referent],
            overview:MarkdownBytecode,
            details:MarkdownBytecode,
            fold:Int?,
            id:ID? = nil)
        {
            self.referents = referents
            self.overview = overview
            self.details = details
            self.fold = fold ?? self.referents.endIndex

            self.id = id
        }
    }
}
extension SymbolGraph.Article
{
    public
    enum CodingKeys:String
    {
        case referents = "R"
        case overview = "O"
        case details = "D"
        case fold = "F"
        case id = "I"
    }
}
extension SymbolGraph.Article:BSONDocumentEncodable, BSONEncodable, BSONWeakEncodable
    where ID:BSONEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.referents] = self.referents.isEmpty ? nil : self.referents
        bson[.overview] = self.overview.isEmpty ? nil : self.overview
        bson[.details] = self.details.isEmpty ? nil : self.details
        bson[.fold] = self.fold == self.referents.endIndex ? nil : self.fold
        //  This is why ``id`` is optional.
        bson[.id] = self.id
    }
}
extension SymbolGraph.Article:BSONDocumentDecodable, BSONDocumentViewDecodable, BSONDecodable
    where ID:BSONDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(referents: try bson[.referents]?.decode() ?? [],
            overview: try bson[.overview]?.decode() ?? [],
            details: try bson[.details]?.decode() ?? [],
            fold: try bson[.fold]?.decode(),
            id: try bson[.id]?.decode())
    }
}
