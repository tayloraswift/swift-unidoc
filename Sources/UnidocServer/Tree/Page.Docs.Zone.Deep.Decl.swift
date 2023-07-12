import HTML
import HTMLRendering
import UnidocRecords

extension Page.Docs.Zone.Deep
{
    struct Decl:Equatable, Sendable
    {
        let extensions:[Record.Extension]
        let entourage:[Record.Master]
        let master:Record.Master
        let zone:Record.Zone.Names

        init(extensions:[Record.Extension],
            entourage:[Record.Master],
            master:Record.Master,
            zone:Record.Zone.Names)
        {
            self.extensions = extensions
            self.entourage = entourage
            self.master = master
            self.zone = zone
        }
    }
}
extension Page.Docs.Zone.Deep.Decl:RenderableAsHTML
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        let context:RenderingContext = .init()

        html[.html]
        {
            $0[.head]
            {
                $0[.title] = "" // "\(self.principal.first?.master?.title))"
            }
            $0[.body]
            {
                $0[.h1] = "" // "\(self.principal.first?.master?.name))"

                self.master.details?.render(to: &$0, with: context)
            }
        }
    }
}
