import HTML
import UnidocAnalysis
import UnidocRecords
import URI

extension Inliner
{
    struct NounTree
    {
        private
        let inliner:Inliner

        let nouns:[Record.Noun]

        init(_ inliner:Inliner, nouns:[Record.Noun])
        {
            self.inliner = inliner

            self.nouns = nouns
        }
    }
}
extension Inliner.NounTree:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        var depth:Int = 0

        for noun:Record.Noun in self.nouns
        {
            let current:Int = noun.depth
            if  current < depth
            {
                for _:Int in current ..< depth
                {
                    html.close(.ul)
                }
            }
            else
            {
                for i:Int in depth ..< current
                {
                    html.open(.ul) { $0.class = i == 0 ? "nountree" : nil }
                }
            }

            depth = current

            html[.li]
            {
                let uri:URI = Site.Docs[self.inliner.zones.principal, noun.shoot]

                $0[.a] { $0.href = "\(uri)" } = noun.top ?
                    noun.shoot.stem.name :
                    noun.shoot.stem.last
            }
        }
        for _:Int in 0 ..< depth
        {
            html.close(.ul)
        }
    }
}
