import BSON
import Unidoc

extension Unidoc.Group
{
    @frozen public
    struct ID:RawRepresentable, Equatable, Hashable, Sendable
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
extension Unidoc.Group.ID
{
    @inlinable public static
    func first(_ plane:Unidoc.Group.Plane, in edition:Unidoc.Edition) -> Self
    {
        .init(rawValue: edition + (plane | 0))
    }
}
extension Unidoc.Group.ID
{
    @inlinable public
    var edition:Unidoc.Edition { self.rawValue.edition }
    @inlinable public
    var package:Unidoc.Package { self.rawValue.package }
    @inlinable public
    var version:Unidoc.Version { self.rawValue.version }

    @inlinable public
    var plane:Unidoc.Group.Plane? { .of(self.rawValue.citizen) }
}
extension Unidoc.Group.ID:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension Unidoc.Group.ID:BSONDecodable, BSONEncodable
{
}
