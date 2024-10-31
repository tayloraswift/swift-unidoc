import MongoDB
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

extension Unidoc
{
    @frozen public
    struct RedirectBySymbolicHintQuery<Predicate>:Equatable, Hashable, Sendable
        where Predicate:VertexPredicate
    {
        public
        let volume:VolumeSelector
        public
        let vertex:Predicate

        @inlinable public
        init(volume:VolumeSelector, lookup vertex:Predicate)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Unidoc.RedirectBySymbolicHintQuery:Mongo.PipelineQuery
{
    public
    typealias CollectionOrigin = Unidoc.DB.Volumes
    public
    typealias Iteration = Mongo.Single<Unidoc.RedirectOutput>

    @inlinable public
    var collation:Mongo.Collation { .casefolding }
    @inlinable public
    var hint:Mongo.CollectionIndex?
    {
        self.volume.version == nil
            ? Unidoc.DB.Volumes.indexSymbolicPatch
            : Unidoc.DB.Volumes.indexSymbolic
    }

    public
    func build(pipeline:inout Mongo.PipelineEncoder)
    {
        if  let version:Substring = self.volume.version
        {
            pipeline.volume(package: self.volume.package, version: version)
        }
        else
        {
            pipeline.volume(package: self.volume.package)
        }

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
