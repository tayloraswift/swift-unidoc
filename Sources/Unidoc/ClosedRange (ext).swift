extension ClosedRange<Unidoc.Edition>
{
    @inlinable public static
    func package(_ package:Int32) -> Self
    {
        .init(package: package, version: Int32.init(bitPattern: .min))
        ...
        .init(package: package, version: Int32.init(bitPattern: .max))
    }
}
