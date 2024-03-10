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
    subscript(put:Put) -> URI { Swiftinit.Root.api / "\(put)" }

    @inlinable public static
    subscript(post:Post, really really:Bool = true) -> URI
    {
        (really ? Swiftinit.Root.api : Swiftinit.Root.really) / "\(post)"
    }
}
