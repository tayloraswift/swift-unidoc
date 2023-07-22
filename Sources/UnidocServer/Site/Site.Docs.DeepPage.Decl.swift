import HTML
import LexicalPaths
import Signatures
import Unidoc
import UnidocRecords
import URI

extension Site.Docs.DeepPage
{
    struct Decl
    {
        let master:Record.Master.Decl
        let tabulator:Tabulator

        private
        init(_ master:Record.Master.Decl, tabulator:Tabulator)
        {
            self.master = master
            self.tabulator = tabulator
        }
    }
}
extension Site.Docs.DeepPage.Decl
{
    init(_ master:Record.Master.Decl, extensions:[Record.Extension], inliner:Inliner)
    {
        self.init(master, tabulator: .init(
            extensions: extensions,
            generics: master.signature.generics.parameters,
            inliner: inliner))
    }
}
extension Site.Docs.DeepPage.Decl
{
    private
    var inliner:Inliner { self.tabulator.inliner }

    var zone:Record.Zone.Names
    {
        self.inliner.zones.principal.zone
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
        guard let path:QualifiedPath = .init(splitting: self.master.stem)
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
            $0[.section, { $0.class = "introduction \(self.master.customization.accent)" }]
            {
                $0[.div, { $0.class = "eyebrows" }]
                {
                    $0[.span] { $0.class = "phylum" } = self.master.phylum.title
                    $0[.span] { $0.class = "version" } = self.zone.version
                    $0[.span, { $0.class = "module" }]
                    {
                        $0 ?= self.master.namespace == self.master.culture ? nil
                            : self.inliner.link(module: self.master.culture)

                        $0[link: self.inliner.uri(self.master.namespace)] = path.namespace
                    }
                }

                $0[.h1] = path.last

                $0 ?= self.master.overview.map(self.inliner.prose(_:))

                $0[.span] { $0.class = "phylum" } = self.master.customization.title
            }

            $0[.section, { $0.class = "declaration" }]
            {
                $0[.pre]
                {
                    $0[.code] = self.inliner.code(self.master.signature.expanded)
                }
            }

            $0[.section] { $0.class = "details" } =
                self.master.details.map(self.inliner.prose(_:))

            if !self.master.superforms.isEmpty
            {
                $0[.section, { $0.class = "superforms" }]
                {
                    $0[.h2] = self.master.phylum.superformHeading(self.master.customization)
                    $0[.ul]
                    {
                        for superform:Unidoc.Scalar in self.master.superforms
                        {
                            $0[.li] = self.inliner.card(superform)
                        }
                    }
                }
            }

            $0 += self.tabulator
        }
    }
}
