import BSONDecoding
import BSONEncoding

@available(*, deprecated, renamed: "Scalar96")
public
typealias GlobalAddress = Scalar96

@frozen public
struct Scalar96:Equatable, Hashable, Sendable
{
    public
    let package:Int32
    public
    let version:Int32
    public
    let citizen:Int32

    @inlinable public
    init(package:Int32, version:Int32, citizen:Int32)
    {
        self.package = package
        self.version = version
        self.citizen = citizen
    }
}
extension Scalar96
{
    @inlinable public
    init(package:Int32, version:Int32, culture:Int)
    {
        self.init(
            package: package,
            version: version,
            citizen: .module | Int32.init(culture))
    }

    @inlinable public
    var culture:Int?
    {
        self.citizen & .module
    }
}
extension Scalar96:BSONRepresentable
{
    @inlinable public
    var bson:BSON.Identifier
    {
        .init(
            .init(bitPattern: self.package),
            .init(bitPattern: self.version),
            .init(bitPattern: self.citizen))
    }
    @inlinable public
    init(_ bson:BSON.Identifier)
    {
        self.init(
            package: .init(bitPattern: bson.timestamp),
            version: .init(bitPattern: bson.middle),
            citizen: .init(bitPattern: bson.low))
    }
}
extension Scalar96:BSONDecodable, BSONEncodable
{
}
extension Scalar96:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.bson < rhs.bson
    }
}
