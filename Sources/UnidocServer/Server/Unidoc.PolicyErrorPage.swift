import HTML
import UnidocRender

extension Unidoc
{
    struct PolicyErrorPage
    {
        let illustration:Unidoc.Asset
        let message:String
        let status:UInt

        init(illustration:Unidoc.Asset, message:String, status:UInt)
        {
            self.illustration = illustration
            self.message = message
            self.status = status
        }
    }
}
extension Unidoc.PolicyErrorPage:Unidoc.StatusBearingPage
{
}
extension Unidoc.PolicyErrorPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
    var title:String { "Policy error" }
}
extension Unidoc.PolicyErrorPage:Unidoc.ApplicationPage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section]
        {
            $0[.p] = self.message
            $0[.img]
            {
                $0.width = "400"
                $0.src = "\(format.assets[self.illustration])"
            }
        }
    }
}
