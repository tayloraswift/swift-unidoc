import HTML
import LexicalPaths
import ModuleGraphs
import Signatures
import Sources
import Unidoc
import UnidocRecords
import URI

extension Site.Docs
{
    struct Decl
    {
        let inliner:Inliner

        private
        let master:Record.Master.Decl
        private
        let groups:[Record.Group]

        private
        let path:QualifiedPath

        init(_ inliner:Inliner, master:Record.Master.Decl, groups:[Record.Group])
        {
            self.inliner = inliner

            self.master = master
            self.groups = groups

            self.path = .init(splitting: self.master.stem)
        }
    }
}
extension Site.Docs.Decl
{
    private
    var zone:Record.Zone
    {
        self.inliner.zones.principal
    }
}
extension Site.Docs.Decl
{
    private
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
}
extension Site.Docs.Decl:FixedPage
{
    var location:URI
    {
        .init(decl: self.master, in: self.zone)
    }

    var title:String
    {
        "\(self.path.last) - \(self.zone.display ?? "\(self.zone.package)") Documentation"
    }

    func emit(header:inout HTML.ContentEncoder)
    {
        header[.nav] { $0.class = "decl" } = self.breadcrumbs
    }

    func emit(main:inout HTML.ContentEncoder)
    {
        let groups:Inliner.Groups = .init(self.inliner,
            superforms: self.master.superforms,
            generics: self.master.signature.generics.parameters,
            groups: self.groups,
            phylum: self.master.phylum,
            kinks: self.master.kinks,
            bias: self.master.culture)

        main[.section]
        {
            $0.class = "introduction"
        }
        content:
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                let demonym:Demonym = .init(
                    phylum: self.master.phylum,
                    kinks: self.master.kinks)

                $0[.span] { $0.class = "phylum" } = demonym
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

            $0 ?= (self.master.overview?.markdown).map(self.inliner.passage(_:))

            if  let location:SourceLocation<Unidoc.Scalar> = self.master.location
            {
                $0 ?= self.inliner.link(file: location.file, line: location.position.line)
            }
        }

        main[.section, { $0.class = "declaration" }]
        {
            $0[.pre]
            {
                $0[.code] = self.inliner.code(self.master.signature.expanded)
            }
        }

        main[.section] { $0.class = "details" } =
            (self.master.details?.markdown).map(self.inliner.passage(_:))

        main += groups
    }
}
