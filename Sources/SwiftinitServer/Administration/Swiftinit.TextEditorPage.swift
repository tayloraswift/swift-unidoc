import HTML
import HTTP
import Media
import MongoDB
import Swiftinit
import SwiftinitRender
import UnidocProfiling
import URI

extension Swiftinit
{
    struct TextEditorPage
    {
        let string:String
        let action:Swiftinit.API.Post

        init(string:String, action:Swiftinit.API.Post)
        {
            self.string = string
            self.action = action
        }
    }
}
extension Swiftinit.TextEditorPage:Swiftinit.DynamicPage
{
}
extension Swiftinit.TextEditorPage:Swiftinit.RenderablePage
{
    var title:String { "Text editor" }
}
extension Swiftinit.TextEditorPage:Swiftinit.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Swiftinit.RenderFormat)
    {
        main[.form]
        {
            $0.enctype = "\(MultipartType.form_data)"
            $0.action = "\(Swiftinit.API[self.action])"
            //  Can’t use PUT with HTML forms.
            $0.method = "post"
        }
            content:
        {
            $0[.textarea] { $0.name = "text" } = self.string
            $0[.button] { $0.type = "submit" } = "Save"
        }
    }
}
