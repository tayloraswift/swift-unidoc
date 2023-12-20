extension UA
{
    @frozen public
    enum Component:Equatable, Hashable, Sendable
    {
        case single(String, Version? = nil)
        case group([String])
    }
}

@_spi(testable)
extension UA.Component
{
    @inlinable public static
    func single(_ name:String, _ major:Int, _ minor:String? = nil) -> Self
    {
        .single(name, .numeric(major, minor))
    }

    @inlinable public static
    func group(_ components:String...) -> Self
    {
        .group(components)
    }
}
