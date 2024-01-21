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
    struct RedirectQuery<Predicate>:Equatable, Hashable, Sendable
        where Predicate:VertexPredicate
    {
        public
        let volume:Unidoc.VolumeSelector
        public
        let vertex:Predicate

        @inlinable public
        init(volume:Unidoc.VolumeSelector, lookup vertex:Predicate)
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
    /// The compiler is capable of inferring this on its own, but this makes it easier to
    /// understand how this type witnesses ``Unidoc.VolumeQuery``.
    public
    typealias VertexPredicate = Predicate

    @inlinable public static
    var volume:Mongo.KeyPath { Unidoc.RedirectOutput[.volume] }

    @inlinable public static
    var input:Mongo.KeyPath { Unidoc.RedirectOutput[.matches] }

    @inlinable public
    var unset:[Mongo.KeyPath]
    {
        [
            Unidoc.AnyVertex[.constituents],
            Unidoc.AnyVertex[.superforms],

            Unidoc.AnyVertex[.overview],
            Unidoc.AnyVertex[.details],
            Unidoc.AnyVertex[.census],
        ]
    }

    @inlinable public
    func extend(pipeline:inout Mongo.PipelineEncoder)
    {
    }
}
