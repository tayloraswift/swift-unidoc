import HTML
import UnidocRecords
import URI

extension Site
{
    struct DisambiguationPage
    {
        let matches:[Record.Master]
        let identity:URI.Path
        let location:URI

        private
        let inliner:Inliner

        init(_ matches:[Record.Master], identity:URI.Path, location:URI, inliner:Inliner)
        {
            self.matches = matches

            self.identity = identity
            self.location = location

            self.inliner = inliner
        }
    }
}
extension Site.DisambiguationPage
{
    var trunk:Record.Trunk
    {
        self.inliner.zones.principal.trunk
    }
}
extension Site.DisambiguationPage:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.section, { $0.class = "introduction" }]
        {
            $0[.div, { $0.class = "eyebrows" }]
            {
                $0[.span, { $0.class = "phylum" }] = "Disambiguation Page"
            }

            $0[.h1] = "\(self.identity)"

            $0[.p] = "This path could refer to multiple entities."
        }
    }
}
