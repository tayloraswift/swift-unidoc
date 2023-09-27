import HTML
import UnidocRecords
import URI

public
protocol ApplicationPage<Navigator>:RenderablePage
{
    associatedtype Navigator:HyperTextOutputStreamable
    var navigator:Navigator { get }

    func main(_:inout HTML.ContentEncoder)
}
extension ApplicationPage<HTML.Logo>
{
    var navigator:HTML.Logo { .init() }
}
extension ApplicationPage
{
    public
    func body(_ body:inout HTML.ContentEncoder)
    {
        body[.header]
        {
            $0[.div, { $0.class = "content" }] { $0[.nav] = self.navigator }
        }
        body[.div]
        {
            $0[.main, { $0.class = "content" }, content: self.main(_:)]
        }
    }
}
