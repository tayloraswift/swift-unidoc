import HTML
import URI

public
protocol AdministrativePage:FixedPage
{
    func main(_:inout HTML.ContentEncoder)
}
extension AdministrativePage
{
    public
    func body(_ body:inout HTML.ContentEncoder)
    {
        body[.header]
        {
            $0[.div, { $0.class = "content" }] { $0[.nav] = HTML.Logo.init() }
        }
        body[.div]
        {
            $0[.main, { $0.class = "content" }, content: self.main(_:)]
        }
    }
}
