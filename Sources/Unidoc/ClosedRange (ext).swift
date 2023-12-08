extension ClosedRange<Unidoc.Edition>
{
    @inlinable public static
    func package(_ package:Unidoc.Package) -> Self
    {
        .init(package: package, version: Unidoc.Version.init(bits: .min))
        ...
        .init(package: package, version: Unidoc.Version.init(bits: .max))
    }
}
extension ClosedRange<Unidoc.Scalar>
{
    @inlinable public static
    func package(_ package:Unidoc.Package) -> Self
    {
        let editions:ClosedRange<Unidoc.Edition> = .package(package)
        return editions.lowerBound.min ... editions.upperBound.max
    }

    @inlinable public static
    func edition(_ edition:Unidoc.Edition) -> Self
    {
        edition.min ... edition.max
    }
}
