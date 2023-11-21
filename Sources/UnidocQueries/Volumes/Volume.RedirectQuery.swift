import MongoQL
import Unidoc
import UnidocDB
import UnidocRecords

@available(*, deprecated, renamed: "Volume.RedirectQuery")
public
typealias ThinQuery = Volume.RedirectQuery

extension Volume
{
    @frozen public
    struct RedirectQuery<VertexPredicate>:Equatable, Hashable, Sendable
        where VertexPredicate:Volume.VertexPredicate
    {
        public
        let volume:Volume.Selector
        public
        let vertex:VertexPredicate

        @inlinable public
        init(volume:Volume.Selector, lookup vertex:VertexPredicate)
        {
            self.volume = volume
            self.vertex = vertex
        }
    }
}
extension Volume.RedirectQuery:DatabaseQuery
{
    public
    typealias Output = Volume.RedirectOutput
}
extension Volume.RedirectQuery:Volume.VertexQuery
{
    @inlinable public static
    var volume:Mongo.KeyPath { Output[.volume] }

    @inlinable public static
    var input:Mongo.KeyPath { Output[.matches] }

    @inlinable public
    func extend(pipeline:inout Mongo.Pipeline)
    {
    }
}
