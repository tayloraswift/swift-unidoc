import FNV1
import HTML
import UnidocSelectors
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
extension StaticRoot
{
    static
    subscript(names:Volume.Meta) -> URI
    {
        var uri:URI = Self.uri

        uri.path.append("\(names.selector)")

        return uri
    }

    static
    subscript(names:Volume.Meta, shoot:Volume.Shoot) -> URI
    {
        var uri:URI = Self[names]

        uri.path += shoot.stem
        uri["hash"] = shoot.hash?.description

        return uri
    }
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
