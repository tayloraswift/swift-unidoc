import BSON
import MongoQL
import UnidocAPI
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct SearchbotTrail:Equatable, Hashable, Sendable
    {
        public
        let trunk:Package
        public
        let shoot:Shoot

        @inlinable public
        init(trunk:Package, shoot:Shoot)
        {
            self.trunk = trunk
            self.shoot = shoot
        }
    }
}
extension Unidoc.SearchbotTrail:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case trunk = "P"
        case stem = "U"
        case hash = "H"
    }
}
extension Unidoc.SearchbotTrail:BSONDocumentEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.trunk] = self.trunk
        bson[.stem] = self.shoot.stem
        bson[.hash] = self.shoot.hash
    }
}
extension Unidoc.SearchbotTrail:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            trunk: try bson[.trunk].decode(),
            shoot: .init(
                stem: try bson[.stem].decode(),
                hash: try bson[.hash]?.decode()))
    }
}
