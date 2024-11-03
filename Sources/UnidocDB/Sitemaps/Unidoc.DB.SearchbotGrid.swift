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
        collation: .casefolding,
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
    func match(vertex:Unidoc.VertexPath, in package:Unidoc.Package) async throws -> Element?
    {
        let id:Unidoc.SearchbotCell.ID = .init(volume: package, vertex: vertex)
        return try await self.find(by: Self.indexCollated, where: id.predicate(_:))
    }

    public
    func count(vertex:Unidoc.VertexPath,
        in volume:Unidoc.Edition,
        as client:Unidoc.Searchbot?,
        at time:UnixAttosecond) async throws
    {
        let id:Unidoc.SearchbotCell.ID = .init(volume: volume.package, vertex: vertex)
        _ = try await self.upsert(by: Self.indexCollated, select: id.predicate(_:))
        {
            //  This will always fail!
            // $0[.setOnInsert]
            // {
            //     $0[Element[.id]] = id
            // }
            $0[.set]
            {
                $0[Element[.ok]] = volume

                let timestamp:Element.CodingKey

                switch client
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

                switch client
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
                $0[.collation] = .casefolding
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
