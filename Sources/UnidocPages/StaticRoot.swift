import FNV1
import HTML
import UnidocRecords
import URI

public
protocol StaticRoot
{
    associatedtype Get = Never
    associatedtype Post = Never

    static
    var root:String { get }
}
extension StaticRoot
{
    @inlinable public static
    var uri:URI { [.push(self.root)] }
}
extension StaticRoot where Get:StaticAPI
{
    static
    subscript(get:Get) -> URI { Self.uri.path / "\(get)" }
}
extension StaticRoot where Post:StaticAPI
{
    static
    subscript(post:Post) -> URI { Self.uri.path / "\(post)" }
}
