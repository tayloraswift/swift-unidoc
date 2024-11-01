import BSON
import FNV1
import MongoQL
import UnidocAPI
import UnidocRecords

extension Unidoc.SearchbotCell
{
    @frozen public
    struct ID:Equatable, Hashable, Sendable
    {
        public
        let volume:Unidoc.Package
        public
        let vertex:Unidoc.VertexPath

        @inlinable public
        init(volume:Unidoc.Package, vertex:Unidoc.VertexPath)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Unidoc.SearchbotCell.ID
{
    func predicate(_ bson:inout Mongo.PredicateEncoder)
    {
        bson[Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.volume]] = self.volume
        bson[Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.stem]] = self.vertex.stem

        if  let hash:FNV24 = self.vertex.hash
        {
            bson[Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.hash]] = hash
        }
        else
        {
            //  Important to specify this, otherwise the query will match
            //  any vertex with the same stem.
            //
            //  Unlike ``DB.Redirects``, we care about this distinction, because
            //  the grid can contain cells from other versions, and we
            bson[Unidoc.SearchbotCell[.id] / Unidoc.SearchbotCell.ID[.hash]] = BSON.Null.init()
        }
    }
}
extension Unidoc.SearchbotCell.ID:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case volume = "P"
        case stem = "U"
        case hash = "H"
    }
}
extension Unidoc.SearchbotCell.ID:BSONDocumentEncodable
{
    @inlinable public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.volume] = self.volume
        bson[.stem] = self.vertex.stem
        bson[.hash] = self.vertex.hash
    }
}
extension Unidoc.SearchbotCell.ID:BSONDocumentDecodable
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
