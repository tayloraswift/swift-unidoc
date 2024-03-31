import HTML
import SwiftinitPages

extension Swiftinit
{
    struct ServerErrorPage
    {
        private
        let error:any Error

        init(error:any Error)
        {
            self.error = error
        }
    }
}
extension Swiftinit.ServerErrorPage:Swiftinit.RenderablePage, Swiftinit.DynamicPage
{
    var title:String { "Internal server error" }
}
extension Swiftinit.ServerErrorPage:Swiftinit.ApplicationPage
{
    typealias Navigator = HTML.Logo

    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.section]
        {
            $0[.p] = """
            Internal server error (type: \(String.init(reflecting: type(of: self.error))))
            """

            $0[.p]
            {
                $0 += "If the issue persists, please "
                $0[.a]
                {
                    $0.href = "https://github.com/tayloraswift/swift-unidoc/issues"
                } = "file an issue"
                $0 += " on GitHub."
            }

            $0[.img]
            {
                $0.width = "400"
                $0.src = "\(format.assets[.error500_jpg])"
                $0.title = "Please retry your request in a moment."
                $0.alt = """
                margot robbie as barbie sitting upright visibly distraught after being bullied
                by four bratz dolls
                """
            }
        }
    }
}
