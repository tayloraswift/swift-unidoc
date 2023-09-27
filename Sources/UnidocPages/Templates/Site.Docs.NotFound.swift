import HTML
import UnidocRecords
import URI

extension Site.Docs
{
    struct NotFound
    {
        private
        let inliner:Inliner
        private
        let nouns:[Volume.Noun]?

        init(_ inliner:Inliner, nouns:[Volume.Noun]? = nil)
        {
            self.inliner = inliner
            self.nouns = nouns
        }
    }
}
extension Site.Docs.NotFound:RenderablePage, DynamicPage
{
    var title:String { "Symbol Not Found - \(self.volume.title)" }
}
extension Site.Docs.NotFound:ApplicationPage
{
    typealias Navigator = HTML.Logo
}
extension Site.Docs.NotFound:VersionedPage
{
    var sidebar:Inliner.TypeTree? { self.nouns.map { .init(self.inliner, nouns: $0) } }

    var volume:Volume.Meta { self.inliner.volumes.principal }

    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.section]
        {
            $0[.p]
            {
                $0 += "Symbol not found. Try a search, or return to the documentation for "
                $0[.a]
                {
                    $0.href = "\(Site.Docs[self.volume])"
                } = self.volume.display ?? "\(self.volume.symbol.package)"
                $0 += "."
            }
        }
    }
}
