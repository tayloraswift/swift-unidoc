import FNV1
import BSON
import MongoDB
import MongoQL
import UnidocRecords
import UnixTime

extension Unidoc.DB
{
    @frozen public
    struct SearchbotGrid
    {
        public
        let database:Mongo.Database
        public
        let session:Mongo.Session

        @inlinable
        init(database:Mongo.Database, session:Mongo.Session)
        {
            self.database = database
            self.session = session
        }
    }
}
extension Unidoc.DB.SearchbotGrid
{
    /// This is not the same as the `_id` index, as it uses a collation.
    ///
    /// Not unique, due to case-folding.
    public
    static let indexCollated:Mongo.CollectionIndex = .init("Collated",
        collation: VolumeCollation.spec,
        unique: false)
    {
        $0[Element[.id] / Element.ID[.volume]] = (+)
        $0[Element[.id] / Element.ID[.stem]] = (+)
        $0[Element[.id] / Element.ID[.hash]] = (+)
    }
}
extension Unidoc.DB.SearchbotGrid:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.SearchbotCell

    @inlinable public static
    var name:Mongo.Collection { "SearchbotGrid/2" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [Self.indexCollated] }
}
extension Unidoc.DB.SearchbotGrid
{
    public
    func match(volume:Unidoc.Package, vertex:Unidoc.VertexPath) async throws -> Element?
    {
        try await self.find
        {
            $0[.filter]
            {
                $0[Element[.id] / Element.ID[.volume]] = volume
                $0[Element[.id] / Element.ID[.stem]] = vertex.stem

                if  let hash:FNV24 = vertex.hash
                {
                    $0[Element[.id] / Element.ID[.hash]] = hash
                }
                else
                {
                    //  Important to specify this, otherwise the query will match
                    //  any vertex with the same stem.
                    //
                    //  Unlike ``DB.Redirects``, we care about this distinction, because
                    //  the grid can contain cells from other versions, and we
                    $0[Element[.id] / Element.ID[.hash]] = BSON.Null.init()
                }
            }
            $0[.hint] = Self.indexCollated.id
            $0[.collation] = VolumeCollation.spec
        }
    }

    public
    func count(searchbot:Unidoc.Searchbot?,
        on trail:Unidoc.SearchbotTrail,
        to docs:Unidoc.Edition,
        at time:UnixAttosecond) async throws
    {
        _ = try await self.modify(upserting: trail)
        {
            $0[.setOnInsert]
            {
                //  This guards against accidentally changing the `_id` due to non-normalized
                //  vertex path strings.
                $0[Element[.id]] = trail
            }
            $0[.set]
            {
                $0[Element[.ok]] = docs

                let timestamp:Element.CodingKey

                switch searchbot
                {
                case nil:           return
                case .bingbot?:     timestamp = .bingbot_fetched
                case .googlebot?:   timestamp = .googlebot_fetched
                case .yandexbot?:   timestamp = .yandexbot_fetched
                }

                $0[Element[timestamp]] = UnixMillisecond.init(truncating: time)
            }
            $0[.inc]
            {
                let counter:Element.CodingKey

                switch searchbot
                {
                case nil:           return
                case .bingbot?:     counter = .bingbot_fetches
                case .googlebot?:   counter = .googlebot_fetches
                case .yandexbot?:   counter = .yandexbot_fetches
                }

                $0[Element[counter]] = 1
            }
        }
    }

    public
    func scroll(package:Unidoc.Package,
        on replica:Mongo.ReadPreference = .nearest,
        yield:([Element]) -> ()) async throws
    {
        try await session.run(
            command: Mongo.Find<Mongo.Cursor<Element>>.init(Self.name,
                stride: 1024)
            {
                $0[.filter] { $0[Element[.id] / Element.ID[.volume]] = package }
                //  Even though this doesn’t actually match on any strings, we still need to
                //  specify the collation in order to use the collated index.
                $0[.collation]  = VolumeCollation.spec
                $0[.hint] = Self.indexCollated.id
            },
            against: self.database,
            on: replica)
        {
            for try await batch:[Element] in $0
            {
                yield(batch)
            }
        }
    }
}
