extension Unidoc
{
    @frozen public
    struct Scalar:Equatable, Hashable, Sendable
    {
        public
        let package:Package
        public
        let version:Version
        public
        let citizen:Int32

        @inlinable public
        init(package:Package, version:Version, citizen:Int32)
        {
            self.package = package
            self.version = version
            self.citizen = citizen
        }
    }
}
extension Unidoc.Scalar:Identifiable
{
    @inlinable public
    var id:Self { self }
}
extension Unidoc.Scalar
{
    @inlinable public
    var edition:Unidoc.Edition { .init(package: self.package, version: self.version) }
}
extension Unidoc.Scalar:CustomStringConvertible
{
    @inlinable public
    var description:String { "\(self.package):\(self.version):\(self.citizen)" }
}
extension Unidoc.Scalar:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool
    {
        (
            a.package.bits,
            a.version.bits,
            UInt32.init(bitPattern: a.citizen)
        )
        <
        (
            b.package.bits,
            b.version.bits,
            UInt32.init(bitPattern: b.citizen)
        )
    }
}
