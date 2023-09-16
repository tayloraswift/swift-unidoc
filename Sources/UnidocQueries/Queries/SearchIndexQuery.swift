
import BSONDecoding
import BSONEncoding
import MD5
import MongoQL
import UnidocAnalysis
import UnidocDB
import UnidocRecords

@frozen public
struct SearchIndexQuery<Database, ID>:Equatable, Hashable, Sendable
    where   Database:DatabaseModel,
            ID:Hashable,
            ID:Sendable,
            ID:BSONDecodable,
            ID:BSONEncodable
{
    public
    let origin:Mongo.Collection
    public
    let tag:MD5?
    public
    let id:ID

    @inlinable public
    init(from origin:Mongo.Collection, tag:MD5?, id:ID)
    {
        self.origin = origin
        self.tag = tag
        self.id = id
    }
}
extension SearchIndexQuery:DatabaseQuery
{
    @inlinable public
    var hint:Mongo.SortDocument? { nil }

    public
    func build(pipeline:inout Mongo.Pipeline)
    {
        pipeline.stage
        {
            $0[.match] = .init
            {
                $0[SearchIndex<ID>[.id]] = self.id
            }
        }

        guard let tag:MD5 = self.tag
        else
        {
            return
        }

        pipeline.stage
        {
            $0[.set] = .init
            {
                $0[SearchIndex<ID>[.json]] = .expr
                {
                    $0[.cond] =
                    (
                        if: .expr { $0[.eq] = (tag, SearchIndex<ID>[.hash]) },
                        then: .expr
                        {
                            $0[.binarySize] = SearchIndex<ID>[.json]
                        },
                        else: SearchIndex<ID>[.json]
                    )
                }
            }
        }
    }
}
