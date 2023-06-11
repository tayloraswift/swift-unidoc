import BSONDecoding
import BSONEncoding
import MarkdownABI

@frozen public
struct MarkdownArticle:Equatable, Sendable
{
    public
    let referents:[Referent]
    public
    let overview:MarkdownBytecode
    public
    let details:MarkdownBytecode
    /// The number of referents used by the overview paragraph alone.
    public
    let fold:Int

    @inlinable public
    init(referents:[Referent],
        overview:MarkdownBytecode,
        details:MarkdownBytecode,
        fold:Int?)
    {
        self.referents = referents
        self.overview = overview
        self.details = details
        self.fold = fold ?? self.referents.endIndex
    }
}
extension MarkdownArticle
{
    public
    enum CodingKeys:String
    {
        case referents = "R"
        case overview = "O"
        case details = "D"
        case fold = "F"
    }
}
extension MarkdownArticle:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.referents] = self.referents.isEmpty ? nil : self.referents
        bson[.overview] = self.overview.isEmpty ? nil : self.overview
        bson[.details] = self.details.isEmpty ? nil : self.details
        bson[.fold] = self.fold == self.referents.endIndex ? nil : self.fold
    }
}
extension MarkdownArticle:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(referents: try bson[.referents]?.decode() ?? [],
            overview: try bson[.overview]?.decode() ?? [],
            details: try bson[.details]?.decode() ?? [],
            fold: try bson[.fold]?.decode())
    }
}
