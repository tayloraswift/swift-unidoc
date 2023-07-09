import BSONDecoding
import UnidocRecords

extension DocpageQuery
{
    struct Output:Equatable, Sendable
    {
        public
        let principal:[Docpage.Principal]
        public
        let entourage:[Record.Master]

        @inlinable public
        init(principal:[Docpage.Principal], entourage:[Record.Master])
        {
            self.principal = principal
            self.entourage = entourage
        }
    }
}

extension DocpageQuery.Output
{
    enum CodingKeys:String
    {
        case principal
        case entourage
    }

    static
    subscript(key:CodingKeys) -> BSON.Key { .init(key) }
}
extension DocpageQuery.Output:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            principal: try bson[.principal].decode(),
            entourage: try bson[.entourage].decode())
    }
}
