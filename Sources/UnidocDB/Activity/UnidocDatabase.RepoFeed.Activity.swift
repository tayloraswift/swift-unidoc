import BSONDecoding
import BSONEncoding
import ModuleGraphs
import MongoQL
import SymbolGraphs
import UnidocRecords

extension UnidocDatabase.RepoFeed
{
    @frozen public
    struct Activity:Identifiable, Equatable, Sendable
    {
        public
        let id:BSON.Millisecond

        public
        let package:PackageIdentifier
        public
        let refname:String
        public
        let origin:Realm.Repo.Origin

        @inlinable public
        init(discovered id:BSON.Millisecond,
            package:PackageIdentifier,
            refname:String,
            origin:Realm.Repo.Origin)
        {
            self.id = id
            self.package = package
            self.refname = refname
            self.origin = origin
        }
    }
}
extension UnidocDatabase.RepoFeed.Activity:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"

        case package = "P"
        case refname = "G"
        case origin = "O"
    }
}
extension UnidocDatabase.RepoFeed.Activity:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.package] = self.package
        bson[.refname] = self.refname
        bson[.origin] = self.origin
    }
}
extension UnidocDatabase.RepoFeed.Activity:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(discovered: try bson[.id].decode(),
            package: try bson[.package].decode(),
            refname: try bson[.refname].decode(),
            origin: try bson[.origin].decode())
    }
}
