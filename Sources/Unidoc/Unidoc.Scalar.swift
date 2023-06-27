extension Unidoc
{
    @frozen public
    struct Scalar:Equatable, Hashable, Sendable
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
}
extension Unidoc.Scalar
{
    @inlinable public
    init(package:Int32, version:Int32, culture:Int)
    {
        self.init(
            package: package,
            version: version,
            citizen: .module | culture)
    }

    @inlinable public
    var culture:Int?
    {
        self.citizen & .module
    }
}
extension Unidoc.Scalar:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (
            UInt32.init(bitPattern: lhs.package),
            UInt32.init(bitPattern: lhs.version),
            UInt32.init(bitPattern: lhs.citizen)
        )
        <
        (
            UInt32.init(bitPattern: rhs.package),
            UInt32.init(bitPattern: rhs.version),
            UInt32.init(bitPattern: rhs.citizen)
        )
    }
}
