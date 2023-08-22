import BSONDecoding
import BSONEncoding

extension Record.Master.Meta
{
    @frozen public
    struct Stats:Equatable, Sendable
    {
        public
        var decls:Decl

        public
        var firstPartyFeatures:Decl
        public
        var thirdPartyFeatures:Decl

        @inlinable public
        init(
            decls:Decl = [:],
            firstPartyFeatures:Decl = [:],
            thirdPartyFeatures:Decl = [:])
        {
            self.decls = decls
            self.firstPartyFeatures = firstPartyFeatures
            self.thirdPartyFeatures = thirdPartyFeatures
        }
    }
}
extension Record.Master.Meta.Stats
{
    public
    enum CodingKey:String
    {
        case decls = "D"
        case firstPartyFeatures = "F"
        case thirdPartyFeatures = "E"
    }
}
extension Record.Master.Meta.Stats:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.decls] = self.decls
        bson[.firstPartyFeatures] = self.firstPartyFeatures
        bson[.thirdPartyFeatures] = self.thirdPartyFeatures
    }
}
extension Record.Master.Meta.Stats:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(decls: try bson[.decls]?.decode() ?? [:],
            firstPartyFeatures: try bson[.firstPartyFeatures]?.decode() ?? [:],
            thirdPartyFeatures: try bson[.thirdPartyFeatures]?.decode() ?? [:])
    }
}
