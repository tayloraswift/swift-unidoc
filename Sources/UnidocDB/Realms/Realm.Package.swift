import BSONDecoding
import BSONEncoding
import MongoQL
import SymbolGraphs
import Symbols
import UnidocRecords
import UnixTime

@available(*, deprecated, renamed: "Realm.Package")
public
typealias PackageRecord = Realm.Package

extension Realm
{
    @frozen public
    struct Package:Identifiable, Equatable, Sendable
    {
        public
        let id:Symbol.Package

        /// The cell-number this package was assigned. Cell numbers can be positive or negative,
        /// but packages that track remote repositories will always have positive cell numbers.
        public
        let coordinate:Int32
        /// The realm this package belongs to. All packages currently belong to the
        /// “``Realm/united``” realm.
        public
        let realm:Realm

        /// The repo this package tracks. Currently only GitHub repos are supported.
        public
        var repo:Repo?
        /// When this package *record* was last crawled. This is different from the time when the
        /// package itself was last updated.
        public
        var crawled:BSON.Millisecond

        @inlinable public
        init(id:Symbol.Package,
            coordinate:Int32,
            realm:Realm,
            repo:Repo? = nil,
            crawled:BSON.Millisecond = 0)
        {
            self.id = id
            self.coordinate = coordinate
            self.realm = realm
            self.repo = repo
            self.crawled = crawled
        }
    }
}
extension Realm.Package:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case coordinate = "P"
        case realm = "r"
        case repo = "R"
        case crawled = "T"
    }
}
extension Realm.Package:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.coordinate] = self.coordinate
        bson[.realm] = self.realm
        bson[.repo] = self.repo
        bson[.crawled] = self.crawled
    }
}
extension Realm.Package:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            coordinate: try bson[.coordinate].decode(),
            realm: try bson[.realm].decode(),
            repo: try bson[.repo]?.decode(),
            crawled: try bson[.crawled]?.decode() ?? 0)
    }
}
