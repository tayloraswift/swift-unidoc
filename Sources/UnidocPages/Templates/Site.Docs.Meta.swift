import HTML
import MarkdownRendering
import ModuleGraphs
import UnidocRecords
import Unidoc
import URI

extension Site.Docs
{
    struct Meta
    {
        let inliner:Inliner

        private
        let master:Record.Master.Meta
        private
        let groups:[Record.Group]

        init(_ inliner:Inliner,
            master:Record.Master.Meta,
            groups:[Record.Group])
        {
            self.inliner = inliner
            self.master = master
            self.groups = groups
        }
    }
}
extension Site.Docs.Meta:FixedPage
{
    var location:URI { Site.Docs[self.zone] }

    var title:String { self.zone.title }

    var zone:Record.Zone { self.inliner.zones.principal }

    func emit(content html:inout HTML.ContentEncoder)
    {
        let groups:Inliner.Groups = .init(inliner,
            groups: self.groups,
            bias: self.master.id,
            mode: .meta)

        html[.section]
        {
            $0.class = "introduction"
        }
        content:
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span] { $0.class = "phylum" } = self.zone.package == .swift ?
                    "Standard Library" :
                    "Package"
            }

            $0[.h1] = self.title

            if  let refname:String = self.zone.refname,
                let github:String = self.zone.github,
                let slash:String.Index = github.firstIndex(of: "/")
            {
                $0 += HTML.SourceLink.init(
                    file: github[github.index(after: slash)...],
                    target: "https://\(github)/tree/\(refname)")
            }
        }

        html += groups
    }
}
