extension Unidoc
{
    @frozen public
    struct Cell:Equatable, Hashable, Sendable
    {
        public
        let package:Int32

        @inlinable public
        init(package:Int32)
        {
            self.package = package
        }
    }
}
extension Unidoc.Cell
{
    @inlinable public
    var min:Unidoc.Edition { self + Int32.init(bitPattern: .min) }
    @inlinable public
    var max:Unidoc.Edition { self + Int32.init(bitPattern: .max) }

    @inlinable public
    func contains(_ scalar:Unidoc.Scalar) -> Bool
    {
        scalar.package == self.package
    }
    @inlinable public
    func contains(_ edition:Unidoc.Edition) -> Bool
    {
        edition.package == self.package
    }
}
extension Unidoc.Cell
{
    @inlinable public static
    func + (self:Self, version:Int32) -> Unidoc.Edition
    {
        .init(package: self.package, version: version)
    }
}
