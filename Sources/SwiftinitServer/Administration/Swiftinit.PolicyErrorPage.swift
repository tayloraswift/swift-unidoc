import HTML
import SwiftinitPages

extension Swiftinit
{
    struct PolicyErrorPage
    {
        let illustration:Swiftinit.Asset
        let message:String

        init(illustration:Swiftinit.Asset, message:String)
        {
            self.illustration = illustration
            self.message = message
        }
    }
}
extension Swiftinit.PolicyErrorPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
    var title:String { "Policy error" }
}
extension Swiftinit.PolicyErrorPage:Unidoc.ApplicationPage
{
    typealias Navigator = HTML.Logo

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
