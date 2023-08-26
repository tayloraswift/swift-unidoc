
import MD5
import BSONDecoding
import BSONEncoding
import MongoQL
import UnidocAnalysis
import UnidocDatabase
import UnidocRecords

@frozen public
struct SearchIndexQuery<ID>:Equatable, Hashable, Sendable
    where   ID:Hashable,
            ID:Sendable,
            ID:BSONDecodable,
            ID:BSONEncodable
{
    public
    let tag:MD5?
    public
    let id:ID

    @inlinable public
    init(tag:MD5?, id:ID)
    {
        self.tag = tag
        self.id = id
    }
}
extension SearchIndexQuery:DatabaseQuery
{
    @inlinable public static
    var collection:Mongo.Collection { Database.Search.name }

    public
    var hint:Mongo.SortDocument { .init { $0["_id"] = (+) } }

    public
    var pipeline:Mongo.Pipeline
    {
        .init
        {
            $0.stage
            {
                $0[.match] = .init
                {
                    $0[Record.SearchIndex<ID>[.id]] = self.id
                }
            }

            $0 ?= self.tag.map
            {
                Stages.Elision.init(
                    field: Record.SearchIndex<ID>[.json],
                    where: Record.SearchIndex<ID>[.hash],
                    is: $0)
            }
        }
    }
}
