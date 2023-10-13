import BSONDecoding
import BSONEncoding
import ModuleGraphs
import MongoQL
import SymbolGraphs

extension UnidocDatabase
{
    @frozen public
    struct RepoActivity:Identifiable, Equatable, Sendable
    {
        public
        let id:BSON.Millisecond

        public
        let package:PackageIdentifier
        public
        let refname:String
        public
        let origin:PackageRepo.Origin

        @inlinable public
        init(discovered id:BSON.Millisecond,
            package:PackageIdentifier,
            refname:String,
            origin:PackageRepo.Origin)
        {
            self.id = id
            self.package = package
            self.refname = refname
            self.origin = origin
        }
    }
}
extension UnidocDatabase.RepoActivity:MongoMasterCodingModel
{
    public
    enum CodingKey:String
    {
        case id = "_id"

        case package = "P"
        case refname = "G"
        case origin = "O"
    }
}
extension UnidocDatabase.RepoActivity:BSONDocumentEncodable
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
extension UnidocDatabase.RepoActivity:BSONDocumentDecodable
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
