import BSON

extension Unidoc.Snapshot
{
    @frozen public
    enum LinkState:Equatable, Sendable
    {
        case initial
        case refresh
    }
}
extension Unidoc.Snapshot.LinkState:RawRepresentable
{
    @inlinable public
    init?(rawValue:Bool) { self = rawValue ? .initial : .refresh }

    @inlinable public
    var rawValue:Bool
    {
        //  DO NOT CONDENSE THIS!
        //  Evaluating `self == .initial` will cause infinite recursion!
        switch self
        {
        case .initial:  true
        case .refresh:  false
        }
    }
}
extension Unidoc.Snapshot.LinkState:BSONDecodable, BSONEncodable
{
}
