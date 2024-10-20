import BSON
import MongoDB
import MongoQL
import UnidocRecords

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
    public static
    let indexPackage:Mongo.CollectionIndex = .init("Package", unique: false)
    {
        $0[Element[.id] / Element.ID[.trunk]] = (+)
    }
}
extension Unidoc.DB.SearchbotGrid:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.SearchbotCell

    @inlinable public static
    var name:Mongo.Collection { "SearchbotGrid" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [Self.indexPackage] }
}
extension Unidoc.DB.SearchbotGrid
{
    public
    func count(searchbot:Unidoc.Searchbot?,
        on trail:Unidoc.SearchbotTrail,
        to docs:Unidoc.Edition) async throws
    {
        _ = try await self.modify(upserting: trail)
        {
            $0[.set]
            {
                $0[Element[.id]] = trail
                $0[Element[.ok]] = docs
            }
            $0[.inc]
            {
                let counter:Element.CodingKey

                switch searchbot
                {
                case nil:           return
                case .bingbot?:     counter = .bingbot
                case .googlebot?:   counter = .googlebot
                case .yandexbot?:   counter = .yandexbot
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
                $0[.filter] { $0[Element[.id] / Element.ID[.trunk]] = package }
                $0[.hint] = Self.indexPackage.id
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
