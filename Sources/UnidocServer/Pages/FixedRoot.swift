import HTML
import URI

protocol FixedRoot
{
    static
    var root:String { get }
}
extension FixedRoot
{
    static
    var uri:URI { [.push(self.root)] }
}
extension FixedRoot where Self:FixedPage
{
    var location:URI { Self.uri }

    func emit(main _:inout HTML.ContentEncoder)
    {
    }
}
