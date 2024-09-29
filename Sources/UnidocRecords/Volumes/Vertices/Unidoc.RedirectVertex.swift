import BSON
import FNV1
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct RedirectVertex:Identifiable
    {
        public
        let id:Redirect
        public
        let stem:Stem
        /// We don’t have any reason to correlate redirects themselves across volumes.
        /// Therefore, we store only the 24-bit hash, to simplify queries.
        public
        let hash:FNV24
        public
        let hashed:Bool

        @inlinable public
        init(id:Redirect, stem:Stem, hash:FNV24, hashed:Bool)
        {
            self.id = id
            self.stem = stem
            self.hash = hash
            self.hashed = hashed
        }
    }
}
extension Unidoc.RedirectVertex
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case stem = "U"
        case hash = "F"
        case hashed = "H"
        /// The target volume, omitted in the schema if it matches the source volume. It is
        /// omitted because in that case, it can be computed from the target vertex coordinate.
        case volume = "E"
    }
}
extension Unidoc.RedirectVertex:BSONDocumentEncodable
{
    public
    func encode(to document:inout BSON.DocumentEncoder<CodingKey>)
    {
        document[.id] = self.id
        document[.stem] = self.stem
        document[.hash] = self.hash
        document[.hashed] = self.hashed ? true : nil

        document[.volume] = self.id.volume != self.id.target.edition
            ? self.id.target.edition
            : nil
    }
}
extension Unidoc.RedirectVertex:BSONDocumentDecodable
{
    public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            stem: try bson[.stem].decode(),
            hash: try bson[.hash].decode(),
            hashed: try bson[.hashed]?.decode() ?? false)
    }
}
