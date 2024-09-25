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
extension Unidoc.DB.SearchbotGrid:Mongo.CollectionModel
{
    public
    typealias Element = Unidoc.SearchbotCoverage

    @inlinable public static
    var name:Mongo.Collection { "SearchbotGrid" }

    @inlinable public static
    var indexes:[Mongo.CollectionIndex] { [] }
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
}
