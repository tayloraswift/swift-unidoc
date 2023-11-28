
import BSONDecoding
import BSONEncoding
import MD5
import MongoDB
import MongoQL
import UnidocDB
import UnidocRecords

@frozen public
struct SearchIndexQuery<ID>:Equatable, Hashable, Sendable
    where   ID:Hashable,
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
extension SearchIndexQuery:Mongo.PipelineQuery
{
    public
    typealias Collation = VolumeCollation

    public
    typealias Iteration = Mongo.Single<Output>

    @inlinable public
    var hint:Mongo.SortDocument? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.match] = .init
        {
            $0[SearchIndex<ID>[.id]] = self.id
        }

        guard let tag:MD5 = self.tag
        else
        {
            return
        }

        pipeline[.set] = .init
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
