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
