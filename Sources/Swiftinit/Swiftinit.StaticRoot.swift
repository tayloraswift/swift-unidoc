import URI

extension Swiftinit
{
    public
    typealias StaticRoot = _SwiftinitStaticRoot
}

/// The name of this protocol is ``Swiftinit.StaticRoot``.
public
protocol _SwiftinitStaticRoot
{
    associatedtype Get = Never
    associatedtype Post = Never

    static
    var root:String { get }
}
extension Swiftinit.StaticRoot
{
    @inlinable public static
    var uri:URI { [.push(self.root)] }
}
extension Swiftinit.StaticRoot where Get:Swiftinit.Method
{
    @inlinable public static
    subscript(get:Get) -> URI { Self.uri.path / "\(get)" }
}
extension Swiftinit.StaticRoot where Post:Swiftinit.Method
{
    @inlinable public static
    subscript(post:Post) -> URI { Self.uri.path / "\(post)" }
}
