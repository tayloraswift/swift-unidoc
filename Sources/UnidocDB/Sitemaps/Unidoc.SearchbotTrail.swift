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
        let volume:Package
        public
        let vertex:VertexPath

        @inlinable public
        init(volume:Package, vertex:VertexPath)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Unidoc.SearchbotTrail:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case volume = "P"
        case stem = "U"
        case hash = "H"
    }
}
extension Unidoc.SearchbotTrail:BSONDocumentEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.volume] = self.volume
        bson[.stem] = self.vertex.stem
        bson[.hash] = self.vertex.hash
    }
}
extension Unidoc.SearchbotTrail:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            volume: try bson[.volume].decode(),
            vertex: .init(
                stem: try bson[.stem].decode(),
                hash: try bson[.hash]?.decode()))
    }
}
