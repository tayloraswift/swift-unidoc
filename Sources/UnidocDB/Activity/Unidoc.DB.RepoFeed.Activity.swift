import BSON
import MongoQL
import SymbolGraphs
import Symbols
import UnidocRecords

extension Unidoc.DB.RepoFeed
{
    @frozen public
    struct Activity:Identifiable, Equatable, Sendable
    {
        public
        let id:BSON.Millisecond

        public
        let package:Symbol.Package
        public
        let refname:String

        @inlinable public
        init(discovered id:BSON.Millisecond,
            package:Symbol.Package,
            refname:String)
        {
            self.id = id
            self.package = package
            self.refname = refname
        }
    }
}
extension Unidoc.DB.RepoFeed.Activity:MongoMasterCodingModel
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "_id"

        case package = "P"
        case refname = "G"

        @available(*, unavailable)
        case origin = "O"
    }
}
extension Unidoc.DB.RepoFeed.Activity:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id

        bson[.package] = self.package
        bson[.refname] = self.refname
    }
}
extension Unidoc.DB.RepoFeed.Activity:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(discovered: try bson[.id].decode(),
            package: try bson[.package].decode(),
            refname: try bson[.refname].decode())
    }
}
