
import BSON
import MD5
import MongoDB
import MongoQL
import UnidocDB
import UnidocRecords

public
typealias SearchIndexQuery = Unidoc.TextResourceQuery

extension Unidoc
{
    @frozen public
    struct TextResourceQuery<CollectionOrigin>:Equatable, Hashable, Sendable
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
}
extension Unidoc.TextResourceQuery:Mongo.PipelineQuery
{
    public
    typealias Collation = VolumeCollation

    public
    typealias Iteration = Mongo.Single<Unidoc.TextResourceOutput>

    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] = .init
        {
            $0[Unidoc.TextResource<CollectionOrigin.Element.ID>[.id]] = self.id
        }

        guard
        let tag:MD5 = self.tag
        else
        {
            return
        }

        pipeline[stage: .set] = .init
        {
            $0[Unidoc.TextResourceOutput[.hash]] =
                Unidoc.TextResource<CollectionOrigin.Element.ID>[.hash]

            $0[Unidoc.TextResourceOutput[.utf8]] = .expr
            {
                $0[.cond] =
                (
                    if: .expr
                    {
                        $0[.eq] =
                        (
                            tag,
                            Unidoc.TextResource<CollectionOrigin.Element.ID>[.hash]
                        )
                    },
                    then: .expr
                    {
                        $0[.binarySize] =
                            Unidoc.TextResource<CollectionOrigin.Element.ID>[.utf8]
                    },
                    else: Unidoc.TextResource<CollectionOrigin.Element.ID>[.utf8]
                )
            }
        }
    }
}

