import Atomics
import HTML
import Media
import UnidocRender

extension Unidoc
{
    struct PluginStatusPage:Sendable
    {
        let messages:[PluginMessage]
        let plugin:any Plugin.Type
        let active:Bool
    }
}
extension Unidoc.PluginStatusPage:Unidoc.RenderablePage, Unidoc.DynamicPage
{
    var title:String { self.plugin.title }
}
extension Unidoc.PluginStatusPage:Unidoc.AdministrativePage
{
    func main(_ main:inout HTML.ContentEncoder, format:Unidoc.RenderFormat)
    {
        main[.h1] = self.title
        main[.form]
        {
            $0.enctype = "\(MediaType.application(.x_www_form_urlencoded))"
            $0.action = "\(Unidoc.ServerRoot.plugin / self.plugin.id)"
            $0.method = "post"
        }
            content:
        {
            $0[.input]
            {
                $0.type = "hidden"
                $0.name = Unidoc.PluginControlForm.active
                $0.value = "\(!self.active)"
            }

            let label:String = self.active ? "Pause plugin" : "Start plugin"

            $0[.button] { $0.class = "region" ; $0.type = "submit" } = label
        }

        main[.section, { $0.class = "events" }]
        {
            $0[.h2] = "Events"
            $0[.ol]
            {
                $0.class = "events"
            } = Unidoc.PluginMessageList<[Unidoc.PluginMessage]>.init(
                items: self.messages,
                now: format.time)
        }
    }
}
