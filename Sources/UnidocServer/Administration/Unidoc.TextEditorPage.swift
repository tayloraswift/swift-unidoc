import HTML
import HTTP
import Media
import MongoDB
import UnidocRender
import UnidocUI
import URI

extension Unidoc
{
    struct TextEditorPage
    {
        let string:String
        let action:Unidoc.PostAction

        init(string:String, action:Unidoc.PostAction)
        {
            self.string = string
            self.action = action
        }
    }
}
extension Unidoc.TextEditorPage:Unidoc.DynamicPage
{
}
extension Unidoc.TextEditorPage:Unidoc.RenderablePage
{
    var title:String { "Text editor" }
}
extension Unidoc.TextEditorPage:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.form]
        {
            $0.enctype = "\(MultipartType.form_data)"
            $0.action = "\(Unidoc.Post[self.action])"
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
