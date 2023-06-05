import BSONDecoding
import BSONEncoding
import ModuleGraphs

extension Documentation
{
    @frozen public
    struct Module:Equatable, Sendable
    {
        public
        let details:ModuleDetails

        /// This module’s binary markdown documentation, if it has any.
        public
        var article:MarkdownArticle?
        /// The range of addresses that contain this module’s scalars,
        /// if it declares any.
        public
        var range:ClosedRange<ScalarAddress>?

        @inlinable public
        init(details:ModuleDetails)
        {
            self.details = details

            self.article = nil
            self.range = nil
        }
    }
}
extension Documentation.Module:Identifiable
{
    @inlinable public
    var id:ModuleIdentifier
    {
        self.details.id
    }
}
extension Documentation.Module
{
    @frozen public
    enum CodingKeys:String
    {
        case article = "A"
        case details = "M"
        case first = "F"
        case last = "L"
    }
}
extension Documentation.Module:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.details] = self.details
        bson[.article] = self.article
        bson[.first] = self.range?.first
        bson[.last] = self.range?.last
    }
}
extension Documentation.Module:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(details: try bson[.details].decode())
        self.article = try bson[.article]?.decode()

        if  let first:ScalarAddress = try bson[.first]?.decode(),
            let last:ScalarAddress = try bson[.last]?.decode()
        {
            self.range = first ... last
        }
    }
}
