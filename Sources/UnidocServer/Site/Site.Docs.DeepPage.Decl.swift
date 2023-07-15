import HTML
import UnidocRecords
import URI

extension Site.Docs.DeepPage
{
    struct Decl
    {
        let master:Record.Master.Decl
        let extensions:[Record.Extension]

        private
        let renderer:Renderer

        init(_ master:Record.Master.Decl,
            extensions:[Record.Extension],
            renderer:Renderer)
        {
            self.master = master
            self.extensions = extensions
            self.renderer = renderer
        }
    }
}
extension Site.Docs.DeepPage.Decl
{
    var zone:Record.Zone.Names
    {
        self.renderer.zones.principal.zone
    }

    var location:URI
    {
        .init(decl: self.master, in: self.zone)
    }
}
extension Site.Docs.DeepPage.Decl:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        guard let path:QualifiedPath = self.master.stem.split()
        else
        {
            return
        }

        html[.head]
        {
            //  TODO: this should include the package name
            $0[.title] = path.last
        }
        html[.body]
        {
            $0[.section, { $0[.class] = "introduction \(self.master.customization.accent)" }]
            {
                $0[.div, { $0[.class] = "eyebrows" }]
                {
                    $0[.span, { $0[.class] = "phylum" }] = self.master.phylum.title

                    $0[.span, { $0[.class] = "module" }]
                    {
                        $0 ?= self.master.namespace == self.master.culture ? nil
                            : self.renderer.link(module: self.master.culture)

                        $0 += self.renderer.link(path.namespace, to: self.master.namespace)
                    }
                }

                $0[.h1] = path.last

                $0 ?= self.renderer.prose(self.master.overview)

                $0[.span, { $0[.class] = "phylum" }] = self.master.customization.title
            }

            $0[.section, { $0[.class] = "declaration" }]
            {
                $0[.pre]
                {
                    $0[.code] = self.renderer.code(self.master.signature.expanded)
                }
            }

            $0[.section] { $0[.class] = "details" } = self.renderer.prose(self.master.details)
        }
    }
}
