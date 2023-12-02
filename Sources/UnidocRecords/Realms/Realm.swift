import BSON

@frozen public
struct Realm:RawRepresentable, Equatable, Hashable, Sendable
{
    public
    let rawValue:Int32

    @inlinable public
    init(rawValue:Int32)
    {
        self.rawValue = rawValue
    }
}
extension Realm
{
    @inlinable public static
    var united:Self { .init(rawValue: 0) }
}
extension Realm:BSONDecodable, BSONEncodable
{
}
