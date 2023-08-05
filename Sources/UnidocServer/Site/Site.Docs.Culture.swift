import HTML
import MarkdownRendering
import ModuleGraphs
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Culture
    {
        private
        let tabulator:Tabulator
        let master:Record.Master.Culture

        private
        init(tabulator:Tabulator, master:Record.Master.Culture)
        {
            self.tabulator = tabulator
            self.master = master
        }
    }
}
extension Site.Docs.Culture
{
    init(_ inliner:Inliner, master:Record.Master.Culture, groups:[Record.Group])
    {
        self.init(
            tabulator: .init(inliner, generics: [], groups: groups),
            master: master)
    }
}
extension Site.Docs.Culture
{
    private
    var inliner:Inliner { self.tabulator.inliner }

    var trunk:Record.Trunk
    {
        self.inliner.zones.principal.trunk
    }
}
extension Site.Docs.Culture:FixedPage
{
    var location:URI
    {
        .init(culture: self.master, in: self.trunk)
    }

    var title:String
    {
        """
        \(self.master.module.name) - \
        \(self.trunk.display ?? "\(self.trunk.package)") Documentation
        """
    }

    func emit(main:inout HTML.ContentEncoder)
    {
        main[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = "Module"
                $0[.span] { $0.class = "version" } = self.trunk.version
            }

            $0[.h1] = self.master.module.name

            $0 ?= self.master.overview.map(self.inliner.passage(_:))

            if  let readme:Unidoc.Scalar = self.master.readme
            {
                $0 ?= self.inliner.link(file: readme)
            }
        }

        main[.section, { $0.class = "declaration" }]
        {
            $0[.pre]
            {
                $0[.code]
                {
                    $0[.span] { $0.highlight = .keyword } = "import"
                    $0 += " "
                    $0[.span] { $0.highlight = .identifier } = self.master.module.id
                }
            }
        }

        main[.section] { $0.class = "details" } =
            self.master.details.map(self.inliner.passage(_:))

        main += self.tabulator
    }
}
