
import BSONDecoding
import BSONEncoding
import MD5
import MongoDB
import MongoQL
import UnidocDB
import UnidocRecords

@frozen public
struct SearchIndexQuery<CollectionOrigin>:Equatable, Hashable, Sendable
    where CollectionOrigin:Mongo.CollectionModel
{
    public
    let tag:MD5?
    public
    let id:CollectionOrigin.Element.ID

    @inlinable public
    init(tag:MD5?, id:CollectionOrigin.Element.ID)
    {
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
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[.match] = .init
        {
            $0[SearchIndex<CollectionOrigin.Element.ID>[.id]] = self.id
        }

        guard let tag:MD5 = self.tag
        else
        {
            return
        }

        pipeline[.set] = .init
        {
            $0[SearchIndex<CollectionOrigin.Element.ID>[.json]] = .expr
            {
                $0[.cond] =
                (
                    if: .expr
                    {
                        $0[.eq] = (tag, SearchIndex<CollectionOrigin.Element.ID>[.hash])
                    },
                    then: .expr
                    {
                        $0[.binarySize] = SearchIndex<CollectionOrigin.Element.ID>[.json]
                    },
                    else: SearchIndex<CollectionOrigin.Element.ID>[.json]
                )
            }
        }
    }
}
