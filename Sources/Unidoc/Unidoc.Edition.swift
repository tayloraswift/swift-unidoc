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
        let package:Package
        public
        let version:Version

        @inlinable public
        init(package:Package, version:Version)
        {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.Edition:RawRepresentable
{
    @inlinable public
    init(rawValue:Int64)
    {
        self.init(
            package: .init(rawValue: Int32.init(rawValue >> 32)),
            version: .init(rawValue: Int32.init(truncatingIfNeeded: rawValue)))
    }
    @inlinable public
    var rawValue:Int64
    {
        Int64.init(self.package.rawValue) << 32 | Int64.init(self.version.bits)
    }
}
extension Unidoc.Edition:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension Unidoc.Edition
{
    @inlinable public
    var min:Unidoc.Scalar { self + Int32.init(bitPattern: .min) }
    @inlinable public
    var max:Unidoc.Scalar { self + Int32.init(bitPattern: .max) }

    @inlinable public
    func contains(_ scalar:Unidoc.Scalar) -> Bool
    {
        scalar.package == self.package &&
        scalar.version == self.version
    }
}
extension Unidoc.Edition
{
    @inlinable public static
    func + (self:Self, citizen:Int32) -> Unidoc.Scalar
    {
        .init(package: self.package, version: self.version, citizen: citizen)
    }

    @inlinable public static
    func - (scalar:Unidoc.Scalar, self:Self) -> Int32?
    {
        self.contains(scalar) ? scalar.citizen : nil
    }
}
