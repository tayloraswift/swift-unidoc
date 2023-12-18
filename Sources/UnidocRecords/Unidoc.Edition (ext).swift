import BSON
import SymbolGraphs
import Unidoc

extension Unidoc.Edition:BSONDecodable, BSONEncodable
{
}
extension Unidoc.Edition
{
    @inlinable public
    subscript(extension i:Int) -> Unidoc.Group.ID
    {
        .init(rawValue: self + i * .extension)
    }
    @inlinable public
    subscript(polygon i:Int) -> Unidoc.Group.ID
    {
        .init(rawValue: self + i * .autogroup)
    }
    @inlinable public
    subscript(topic i:Int) -> Unidoc.Group.ID
    {
        .init(rawValue: self + i * .topic)
    }
}
extension Unidoc.Edition
{
    @inlinable public
    var global:Unidoc.Scalar { self + 0 * .global }

    /// A shorthand for `self + culture * .module`.
    @inlinable public static
    func + (self:Self, culture:Int) -> Unidoc.Scalar
    {
        self + culture * .module
    }

    @inlinable public static
    func - (scalar:(value:Unidoc.Scalar, as:SymbolGraph.Plane), self:Self) -> Int?
    {
        self.contains(scalar.value) ? (scalar.value.citizen / scalar.as) : nil
    }
}
