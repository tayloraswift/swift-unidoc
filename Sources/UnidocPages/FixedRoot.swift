import FNV1
import HTML
import UnidocSelectors
import UnidocRecords
import URI

public
protocol FixedRoot
{
    associatedtype Get = Never
    associatedtype Post = Never

    static
    var root:String { get }
}
extension FixedRoot
{
    @inlinable public static
    var uri:URI { [.push(self.root)] }
}
extension FixedRoot
{
    static
    subscript(names:Volume.Names) -> URI
    {
        var uri:URI = Self.uri

        uri.path += names

        return uri
    }

    static
    subscript(names:Volume.Names, shoot:Volume.Shoot) -> URI
    {
        var uri:URI = Self[names]

        uri.path += shoot.stem
        uri["hash"] = shoot.hash?.description

        return uri
    }
}
extension FixedRoot where Get:FixedAPI
{
    static
    subscript(get:Get) -> URI { Self.uri.path / "\(get)" }
}
extension FixedRoot where Post:FixedAPI
{
    static
    subscript(post:Post) -> URI { Self.uri.path / "\(post)" }
}
