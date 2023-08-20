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
        let nouns:[Record.Noun]

        init(_ inliner:Inliner,
            master:Record.Master.Decl,
            groups:[Record.Group],
            nouns:[Record.Noun])
        {
            self.inliner = inliner

            self.master = master
            self.groups = groups
            self.nouns = nouns
        }
    }
}
extension Site.Docs.Decl
{
    private
    var stem:Record.Stem { self.master.stem }
}
extension Site.Docs.Decl
{
    private
    var breadcrumbs:Inliner.Breadcrumbs?
    {
        if  let (_, scope, last):(Substring, [Substring], Substring) = self.stem.split()
        {
            return .init(
                scope: self.master.scope.isEmpty ? nil : self.inliner.link(scope,
                    to: self.master.scope),
                last: last)
        }
        else
        {
            return nil
        }
    }
}
extension Site.Docs.Decl:FixedPage
{
    var location:URI { Site.Docs[self.zone, self.master.shoot] }

    var title:String
    {
        """
        \(self.master.stem.last) - \
        \(self.zone.display ?? "\(self.zone.package)") Documentation
        """
    }

    var zone:Record.Zone { self.inliner.zones.principal }

    var sidebar:Inliner.NounTree?
    {
        .init(self.inliner, nouns: self.nouns)
    }

    func emit(header:inout HTML.ContentEncoder)
    {
        header[.nav] { $0.class = "decl" } = self.breadcrumbs
        header[.div, { $0.class = "searchbar-container" }]
        {
            $0[.div, { $0.class = "searchbar" }]
            {
                $0[.form, { $0.id = "search" ; $0.role = "search" }]
                {
                    $0[.input]
                    {
                        $0.id = "search-input"
                        $0.type = "search"
                        $0.placeholder = "search symbols"
                        $0.autocomplete = "off"
                    }
                }
            }
        }
        header[.div, { $0.class = "search-results-container" }]
        {
            $0[.ol] { $0.id = "search-results" }
        }
    }

    func emit(content html:inout HTML.ContentEncoder)
    {
        let groups:Inliner.Groups = .init(self.inliner,
            requirements: self.master.requirements,
            superforms: self.master.superforms,
            generics: self.master.signature.generics.parameters,
            groups: self.groups,
            phylum: self.master.phylum,
            kinks: self.master.kinks,
            bias: self.master.culture)

        html[.section]
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
                    $0[link: self.inliner.url(self.master.namespace)] = self.stem.first
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

            $0[.h1] = self.stem.last

            $0 ?= (self.master.overview?.markdown).map(self.inliner.passage(_:))

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
            (self.master.details?.markdown).map(self.inliner.passage(_:))

        html += groups
    }
}
