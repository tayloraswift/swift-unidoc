import FNV1
import HTML
import UnidocSelectors
import UnidocRecords
import URI

public
protocol FixedRoot
{
    static
    var root:String { get }
}
extension FixedRoot
{
    @inlinable public static
    var uri:URI { [.push(self.root)] }
}
extension FixedRoot where Self:CustomStringConvertible, Self:RawRepresentable<String>
{
    @inlinable public
    var description:String { "/\(Self.root)/\(self.rawValue)" }
}
extension FixedRoot
{
    static
    subscript(names:Volume.Names) -> URI
    {
        var uri:URI = Self.uri ; uri.path += names ; return uri
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
