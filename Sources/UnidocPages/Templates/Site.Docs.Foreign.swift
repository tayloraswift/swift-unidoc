import Availability
import HTML
import LexicalPaths
import MarkdownABI
import ModuleGraphs
import Signatures
import Sources
import Unidoc
import UnidocRecords
import URI

extension Site.Docs
{
    struct Foreign
    {
        let context:VersionedPageContext

        let canonical:CanonicalVersion?
        let sidebar:[Volume.Noun]?

        private
        let vertex:Volume.Vertex.Foreign
        private
        let groups:[Volume.Group]

        init(_ context:VersionedPageContext,
            canonical:CanonicalVersion?,
            sidebar:[Volume.Noun]?,
            vertex:Volume.Vertex.Foreign,
            groups:[Volume.Group])
        {
            self.context = context
            self.canonical = canonical
            self.sidebar = sidebar
            self.vertex = vertex
            self.groups = groups
        }
    }
}
extension Site.Docs.Foreign
{
    private
    var stem:Volume.Stem { self.vertex.stem }
}
extension Site.Docs.Foreign:RenderablePage
{
    var title:String { "\(self.stem.last) - \(self.volume.title)" }

    var description:String?
    {
        let what:Site.Docs.Decl.Demonym = .init(phylum: self.vertex.phylum,
            kinks: self.vertex.kinks)

        return """
            \(self.stem.last), \(what) from \(self.stem.first), has extensions available \
            in the package \(self.volume.display ?? "\(self.volume.symbol.package)").
            """
    }
}
extension Site.Docs.Foreign:StaticPage
{
    var location:URI { Site.Docs[self.volume, self.vertex.shoot] }
}
extension Site.Docs.Foreign:ApplicationPage
{
    var navigator:Breadcrumbs
    {
        if  let (_, scope, last):(Substring, [Substring], Substring) = self.stem.split()
        {
            .init(scope: self.vertex.scope.isEmpty ?
                    nil : self.context.vectorLink(components: scope, to: self.vertex.scope),
                last: last)
        }
        else
        {
            .init(scope: nil,
                last: self.stem.last)
        }
    }
}
extension Site.Docs.Foreign:VersionedPage
{
    func main(_ main:inout HTML.ContentEncoder)
    {
        let groups:GroupSections = .init(self.context,
            groups: self.groups,
            bias: nil,
            mode: .decl(self.vertex.flags.phylum, self.vertex.flags.kinks))

        main += groups
    }
}
