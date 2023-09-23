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
extension Site.Docs.NotFound
{
    private
    var names:Volume.Names { self.inliner.names.principal }
}
extension Site.Docs.NotFound:RenderablePage
{
    var title:String { "Symbol Not Found - \(self.names.title)" }
}
extension Site.Docs.NotFound:DynamicPage
{
}
extension Site.Docs.NotFound:ApplicationPage
{
    typealias Navigator = HTML.Logo

    var sidebar:Inliner.TypeTree? { self.nouns.map { .init(self.inliner, nouns: $0) } }

    var volume:VolumeIdentifier { self.names.volume }

    func main(_ main:inout HTML.ContentEncoder)
    {
        main[.section]
        {
            $0[.p]
            {
                $0 += "Symbol not found. Try a search, or return to the documentation for "
                $0[.a]
                {
                    $0.href = "\(Site.Docs[self.names])"
                } = self.names.display ?? "\(self.names.package)"
                $0 += "."
            }
        }
    }
}
