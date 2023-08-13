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
extension FixedRoot where Self:FixedPage
{
    @inlinable public
    var location:URI { Self.uri }

    @inlinable public
    func emit(main _:inout HTML.ContentEncoder)
    {
    }
}
extension FixedRoot where Self:CustomStringConvertible, Self:RawRepresentable<String>
{
    @inlinable public
    var description:String { "/\(Self.root)/\(self.rawValue)" }
}
extension FixedRoot
{
    static
    subscript(zone:Record.Zone, shoot:Record.Shoot) -> URI
    {
        var uri:URI = Self.uri

        uri.path += zone
        uri.path += shoot.stem

        uri["hash"] = shoot.hash?.description

        return uri
    }
}
