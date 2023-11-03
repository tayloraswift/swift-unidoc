extension Unidoc
{
    @available(*, deprecated, renamed: "Edition")
    public
    typealias Zone = Edition
}
extension Unidoc
{
    @frozen public
    struct Edition:Equatable, Hashable, Sendable
    {
        public
        let package:Int32
        public
        let version:Int32

        @inlinable public
        init(package:Int32, version:Int32)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.Edition
{
    @inlinable public
    var global:Unidoc.Scalar { self + 0 * .global }

    @inlinable public
    var min:Unidoc.Scalar { self + Int32.init(bitPattern: .min) }
    @inlinable public
    var max:Unidoc.Scalar { self + Int32.init(bitPattern: .max) }

    @inlinable public
    var cell:Unidoc.Cell { .init(package: self.package) }

    @inlinable public
    func contains(_ scalar:Unidoc.Scalar) -> Bool
    {
        scalar.package == self.package &&
        scalar.version == self.version
    }
}
extension Unidoc.Edition
{
    /// A shorthand for `self + culture * .module`.
    @inlinable public static
    func + (self:Self, culture:Int) -> Unidoc.Scalar
    {
        self + culture * .module
    }

    @inlinable public static
    func + (self:Self, citizen:Int32) -> Unidoc.Scalar
    {
        .init(package: self.package, version: self.version, citizen: citizen)
    }
}
extension Unidoc.Edition
{
    @inlinable public static
    func - (scalar:Unidoc.Scalar, self:Self) -> Int32?
    {
        self.contains(scalar) ? scalar.citizen : nil
    }
    @inlinable public static
    func - (scalar:(value:Unidoc.Scalar, as:UnidocPlane), self:Self) -> Int?
    {
        self.contains(scalar.value) ? (scalar.value.citizen / scalar.as) : nil
    }
}