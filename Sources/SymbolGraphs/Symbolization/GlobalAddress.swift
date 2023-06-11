import BSONDecoding
import BSONEncoding

@frozen public
struct GlobalAddress:Equatable, Hashable, Sendable
{
    public
    let package:Int32
    public
    let version:Int32
    public
    let citizen:UInt32

    @inlinable public
    init(package:Int32, version:Int32, citizen:UInt32)
    {
        self.package = package
        self.version = version
        self.citizen = citizen
    }
}
extension GlobalAddress:BSONRepresentable
{
    @inlinable public
    var bson:BSON.Identifier
    {
        .init(.init(bitPattern: self.package), .init(bitPattern: self.version), self.citizen)
    }
    @inlinable public
    init(_ bson:BSON.Identifier)
    {
        self.init(package: .init(bitPattern: bson.timestamp),
            version: .init(bitPattern: bson.middle),
            citizen: bson.low)
    }
}
extension GlobalAddress:BSONDecodable, BSONEncodable
{
}
extension GlobalAddress:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.bson < rhs.bson
    }
}
