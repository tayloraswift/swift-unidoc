import URI

extension Swiftinit
{
    @frozen public
    enum API
    {
    }
}
extension Swiftinit.API
{
    @inlinable public static
    subscript(get:Get) -> URI { Swiftinit.Root.api / "\(get)" }

    @inlinable public static
    subscript(post:Post) -> URI { Swiftinit.Root.api / "\(post)" }

    @inlinable public static
    subscript(put:Put) -> URI { Swiftinit.Root.api / "\(put)" }
}
