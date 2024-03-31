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
extension Swiftinit.PolicyErrorPage:Swiftinit.RenderablePage, Swiftinit.DynamicPage
{
    var title:String { "Policy error" }
}
extension Swiftinit.PolicyErrorPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo

    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
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
