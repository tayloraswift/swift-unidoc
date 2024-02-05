import BSON
import Durations
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

        @inlinable public
        init(id:Unidoc.Package,
            symbol:Symbol.Package,
            hidden:Bool = false,
            realm:Unidoc.Realm? = nil,
            realmAligning:Bool = false,
            repo:PackageRepo? = nil)
        {
            self.id = id
            self.symbol = symbol
            self.hidden = hidden
            self.realm = realm
            self.realmAligning = realmAligning
            self.repo = repo
        }
    }
}
extension Unidoc.PackageMetadata
{
    mutating
    func crawled(repo:consuming Unidoc.PackageRepo)
    {
        schedule:
        if  let interval:Milliseconds = repo.crawlingIntervalTarget(
                hidden: self.hidden,
                realm: self.realm)
        {
            let target:BSON.Millisecond = repo.crawled.advanced(by: interval)

            //  If the repo is already scheduled to have its tags read, we should not keep
            //  postponing that.
            if  let expires:BSON.Millisecond = repo.expires,
                    expires < target
            {
                break schedule
            }

            repo.expires = target
        }
        else
        {
            repo.expires = nil
        }

        self.repo = repo
    }

    public mutating
    func fetched(repo:consuming Unidoc.PackageRepo)
    {
        repo.fetched = repo.crawled

        if  let interval:Milliseconds = repo.crawlingIntervalTarget(
                hidden: self.hidden,
                realm: self.realm)
        {
            repo.expires = repo.crawled.advanced(by: interval)
        }
        else
        {
            repo.expires = nil
        }

        self.repo = repo
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

        @available(*, unavailable)
        case crawled = "C"
        @available(*, unavailable)
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
    }
}
extension Unidoc.PackageMetadata:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            symbol: try bson[.symbol].decode(),
            hidden: try bson[.hidden]?.decode() ?? false,
            realm: try bson[.realm]?.decode(),
            realmAligning: try bson[.realmAligning]?.decode() ?? false,
            repo: try bson[.repo]?.decode())
    }
}
extension Unidoc.PackageMetadata
{
    public
    var crawlingIntervalTarget:Milliseconds?
    {
        self.repo?.crawlingIntervalTarget(hidden: self.hidden, realm: self.realm)
    }
}
