import BSON
import MongoQL
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords
import UnixTime

extension Unidoc
{
    @frozen public
    struct PackageMetadata:Identifiable, Sendable
    {
        /// The coordinate this package was assigned. All package coordinates are currently
        /// positive.
        ///
        /// Package coordinates cannot be used to distinguish any package characteristic that
        /// can change, because the coordinate can never change. Tracking a remote GitHub repo
        /// counts as something that can change.
        public
        let id:Package

        /// The current preferred name for this package. A package may have multiple names,
        /// and the preferred name can change.
        public
        var symbol:Symbol.Package

        /// Indicates whether this package is hidden from the public.
        public
        var hidden:Bool

        /// The current realm this package belongs to. A package can change realms.
        public
        var realm:Realm?
        /// Indicates if this package is currently undergoing realm alignment.
        public
        var realmAligning:Bool

        /// The remote git repo this package tracks.
        ///
        /// Currently only GitHub repos are supported.
        public
        var repo:PackageRepo?

        /// When this package *record* was last crawled. This is different from the time when
        /// the package itself was last updated.
        public
        var crawled:BSON.Millisecond?
        /// When this package will become stale for the crawl scheduler.
        ///
        /// Packages that we want to crawl frequently will expire instantly – that is, they
        /// have an expiration equal to ``crawled``.
        ///
        /// Packages we want to crawl less frequently have an expiration in the future.
        public
        var expires:BSON.Millisecond

        @inlinable public
        init(id:Unidoc.Package,
            symbol:Symbol.Package,
            hidden:Bool = false,
            realm:Unidoc.Realm? = nil,
            realmAligning:Bool = false,
            repo:PackageRepo? = nil,
            crawled:BSON.Millisecond? = nil,
            expires:BSON.Millisecond = 0)
        {
            self.id = id
            self.symbol = symbol
            self.hidden = hidden
            self.realm = realm
            self.realmAligning = realmAligning
            self.repo = repo
            self.crawled = crawled
            self.expires = expires
        }
    }
}
extension Unidoc.PackageMetadata:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case symbol = "Y"
        case hidden = "H"
        case realm = "r"
        case realmAligning = "A"

        case repo = "G"

        @available(*, unavailable)
        case repoLegacy = "R"

        case crawled = "C"
        case expires = "T"
    }
}
extension Unidoc.PackageMetadata:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.symbol] = self.symbol
        bson[.hidden] = self.hidden ? true : nil
        bson[.realm] = self.realm
        bson[.realmAligning] = self.realmAligning ? true : nil
        bson[.repo] = self.repo
        bson[.crawled] = self.crawled
        bson[.expires] = self.expires
    }
}
extension Unidoc.PackageMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(),
            symbol: try bson[.symbol].decode(),
            hidden: try bson[.hidden]?.decode() ?? false,
            realm: try bson[.realm]?.decode(),
            realmAligning: try bson[.realmAligning]?.decode() ?? false,
            repo: try bson[.repo]?.decode(),
            crawled: try bson[.crawled]?.decode(),
            expires: try bson[.expires]?.decode() ?? 0)
    }
}
extension Unidoc.PackageMetadata
{
    public
    var crawlingIntervalTargetDays:Int64?
    {
        guard
        let repo:Unidoc.PackageRepo = self.repo
        else
        {
            return nil
        }

        guard repo.origin.alive
        else
        {
            //  Repo has been deleted from, archived in, or disabled by the registrar.
            return 30
        }

        var days:Int64 = 0

        switch repo.license?.free
        {
        //  The license is free.
        case true?:     break
        //  No license. The package is probably new and the author hasn’t gotten around to
        //  adding a license yet.
        case nil:       days += 3
        //  The license is intentionally unfree.
        case false?:    days += 14
        }

        //  Deprioritize hidden packages.
        if  self.hidden
        {
            days += 1
        }
        //  Prioritize packages with more stars. (We currently only index packages with at
        //  least two stars.)
        //
        //  If the package is part of the `public` realm (or whatever realm `0` has been named),
        //  we consider it to have infinite stars.
        if  case 0? = self.realm
        {
            return days
        }

        switch repo.stars
        {
        case  0 ...  2: days += 3
        case  3 ... 10: days += 2
        case 11 ... 20: days += 1
        default:        break
        }

        return days
    }
}
