import MongoDB
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    struct RedirectByInternalHintQuery<Predicate>:Equatable, Hashable, Sendable
        where Predicate:VertexPredicate
    {
        let volume:Edition
        let vertex:Predicate

        init(volume:Edition, lookup vertex:Predicate)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Unidoc.RedirectByInternalHintQuery:Mongo.PipelineQuery
{
    typealias CollectionOrigin = Unidoc.DB.Volumes
    typealias Iteration = Mongo.Single<Unidoc.RedirectOutput>

    var collation:Mongo.Collation { .casefolding }
    var hint:Mongo.CollectionIndex? { nil }

    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        pipeline[stage: .match] { $0[Unidoc.VolumeMetadata[.id]] = self.volume }
        pipeline[stage: .replaceWith, using: Unidoc.RedirectOutput.CodingKey.self]
        {
            $0[.volume] = Mongo.Pipeline.ROOT
        }

        pipeline.lookup(vertex: self.vertex,
            volume: Unidoc.RedirectOutput[.volume],
            output: Unidoc.RedirectOutput[.matches],
            fields: .limited)
    }
}
