import BSON
import Unidoc

extension Unidoc
{
    @frozen public
    struct Group:RawRepresentable, Equatable, Hashable, Sendable
    {
        public
        let rawValue:Unidoc.Scalar

        @inlinable public
        init(rawValue:Unidoc.Scalar)
        {
            self.rawValue = rawValue
        }
    }
}
extension Unidoc.Group
{
    @available(*, deprecated, renamed: "Unidoc.ExtensionGroup")
    public
    typealias Extension = Unidoc.ExtensionGroup

    @available(*, deprecated, renamed: "Unidoc.PolygonalGroup")
    public
    typealias Automatic = Unidoc.PolygonalGroup

    @available(*, deprecated, renamed: "Unidoc.PolygonalGroup")
    public
    typealias Polygon = Unidoc.PolygonalGroup

    @available(*, deprecated, renamed: "Unidoc.TopicGroup")
    public
    typealias Topic = Unidoc.TopicGroup

    @inlinable public
    var edition:Unidoc.Edition { self.rawValue.edition }
    @inlinable public
    var package:Unidoc.Package { self.rawValue.package }
    @inlinable public
    var version:Unidoc.Version { self.rawValue.version }

    @inlinable public
    var plane:Unidoc.GroupType? { .of(self.rawValue.citizen) }
}
extension Unidoc.Group:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension Unidoc.Group:BSONDecodable, BSONEncodable
{
}
