import MongoQL
import Unidoc
import UnidocRecords

@frozen public
struct ThinQuery<LookupPredicate>:Equatable, Hashable, Sendable
    where LookupPredicate:VolumeLookupPredicate
{
    public
    let volume:Volume.Selector
    public
    let lookup:LookupPredicate

    @inlinable public
    init(volume:Volume.Selector, lookup:LookupPredicate)
    {
        self.volume = volume
        self.lookup = lookup
    }
}
extension ThinQuery:VolumeLookupQuery
{
    @inlinable public static
    var names:Mongo.KeyPath { Output[.names] }

    @inlinable public static
    var input:Mongo.KeyPath { Output[.masters] }

    @inlinable public
    func extend(pipeline:inout Mongo.Pipeline)
    {
    }
}
