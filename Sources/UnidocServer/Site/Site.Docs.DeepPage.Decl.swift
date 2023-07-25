import HTML
import LexicalPaths
import ModuleGraphs
import Signatures
import Sources
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
        let path:QualifiedPath

        private
        init(_ master:Record.Master.Decl, tabulator:Tabulator)
        {
            self.master = master
            self.tabulator = tabulator

            self.path = .init(splitting: self.master.stem)
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
extension Site.Docs.DeepPage.Decl
{
    var breadcrumbs:Inliner.Breadcrumbs?
    {
        if  let last:Int = self.path.names.indices.last
        {
            return .init(last == self.path.names.startIndex ? nil :
                self.inliner.link(self.path.names[..<last], to: self.master.scope),
                self.path.names[last])
        }
        else
        {
            return nil
        }
    }

    var title:String
    {
        "\(self.path.last) - \(self.zone.display ?? "\(self.zone.package)") Documentation"
    }
}
extension Site.Docs.DeepPage.Decl:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.section]
        {
            $0.class = self.master.customization.accent.map
            {
                "introduction \($0)"
            } ?? "introduction"
        }
        content:
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.master.phylum.title
                $0[.span, { $0.class = "module" }]
                {
                    $0[link: self.inliner.url(self.master.namespace)] = self.path.namespace
                    $0[.span, { $0.class = "culture" }]
                    {
                        $0[.span] { $0.class = "version" } = self.zone.version
                        if  self.master.namespace != self.master.culture
                        {
                            $0 ?= self.inliner.link(module: self.master.culture)
                        }
                    }
                }
            }

            $0[.h1] = self.path.last

            $0 ?= self.master.overview.map(self.inliner.passage(_:))

            $0[.span] { $0.class = "customization" } = self.master.customization.title

            if  let location:SourceLocation<Unidoc.Scalar> = self.master.location
            {
                $0 ?= self.inliner.link(file: location.file, line: location.position.line)
            }
        }

        html[.section, { $0.class = "declaration" }]
        {
            $0[.pre]
            {
                $0[.code] = self.inliner.code(self.master.signature.expanded)
            }
        }

        html[.section] { $0.class = "details" } =
            self.master.details.map(self.inliner.passage(_:))

        if !self.master.superforms.isEmpty
        {
            html[.section, { $0.class = "superforms" }]
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

        html += self.tabulator
    }
}
