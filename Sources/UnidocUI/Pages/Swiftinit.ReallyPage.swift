import HTML
import Media
import UnidocRender
import URI

extension Swiftinit
{
    @frozen public
    struct ReallyPage
    {
        public
        let title:String
        @usableFromInline
        let prompt:String
        @usableFromInline
        let button:String

        @usableFromInline
        let action:URI

        @inlinable public
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
extension Swiftinit.ReallyPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
}
extension Swiftinit.ReallyPage:Unidoc.ApplicationPage
{
    public
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.h1] = self.title
        }

        main[.section, { $0.class = "details" }]
        {
            $0[.form]
            {
                $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
                $0.action = "\(self.action.path)"
                $0.method = "post"
            }
                content:
            {
                $0[.p] = self.prompt
                $0[.p]
                {
                    $0[.button] { $0.class = "area" ; $0.type = "submit" } = self.button
                }

                guard
                let query:URI.Query = self.action.query
                else
                {
                    return
                }

                for (key, value):(String, String) in query.parameters
                {
                    $0[.input]
                    {
                        $0.type = "hidden"
                        $0.name = key
                        $0.value = value
                    }
                }
            }
        }
    }
}
