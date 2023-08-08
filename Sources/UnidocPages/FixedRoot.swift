import HTML
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
