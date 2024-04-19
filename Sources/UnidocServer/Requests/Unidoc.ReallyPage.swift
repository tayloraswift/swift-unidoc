import HTML
import Media
import URI

extension Unidoc
{
    /// A basic confirmation page that displays a single-sentence prompt.
    struct ReallyPage
    {
        let title:String
        let prompt:String
        let button:String

        let action:URI

        init(title:String,
            prompt:String,
            button:String,
            action:URI)
        {
            self.title = title
            self.prompt = prompt
            self.button = button
            self.action = action
        }
    }
}
extension Unidoc.ReallyPage:Unidoc.ConfirmationPage
{
    func form(_ form:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        form[.p] = self.prompt
    }
}
