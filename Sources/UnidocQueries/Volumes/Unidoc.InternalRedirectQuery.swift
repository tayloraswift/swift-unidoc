import MongoDB
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct InternalRedirectQuery<Predicate>:Equatable, Hashable, Sendable
        where Predicate:VertexPredicate
    {
        public
        let volume:Edition
        public
        let vertex:Predicate

        @inlinable public
        init(volume:Edition, lookup vertex:Predicate)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Unidoc.InternalRedirectQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Volumes
    public
    typealias Collation = VolumeCollation
    public
    typealias Iteration = Mongo.Single<Unidoc.RedirectOutput>

    @inlinable public
    var hint:Mongo.CollectionIndex? { nil }

    public
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
