import MongoDB
import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

@available(*, deprecated, renamed: "Unidoc.RedirectQuery")
public
typealias ThinQuery = Unidoc.RedirectQuery

extension Unidoc
{
    @frozen public
    struct RedirectQuery<VertexPredicate>:Equatable, Hashable, Sendable
        where VertexPredicate:Unidoc.VertexPredicate
    {
        public
        let volume:Unidoc.VolumeSelector
        public
        let vertex:VertexPredicate

        @inlinable public
        init(volume:Unidoc.VolumeSelector, lookup vertex:VertexPredicate)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Unidoc.RedirectQuery:Mongo.PipelineQuery
{
    public
    typealias Iteration = Mongo.Single<Unidoc.RedirectOutput>
}
extension Unidoc.RedirectQuery:Unidoc.VolumeQuery
{
    @inlinable public static
    var volume:Mongo.KeyPath { Unidoc.RedirectOutput[.volume] }

    @inlinable public static
    var input:Mongo.KeyPath { Unidoc.RedirectOutput[.matches] }

    @inlinable public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
    }
}
