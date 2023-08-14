import HTML
import UnidocAnalysis
import UnidocRecords
import URI

extension Inliner
{
    struct TypeTree
    {
        private
        let inliner:Inliner

        let types:[Record.TypeTree.Row]

        init(_ inliner:Inliner, types:[Record.TypeTree.Row])
        {
            self.inliner = inliner

            self.types = types
        }
    }
}
extension Inliner.TypeTree:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        var depth:Int = 0

        for type:Record.TypeTree.Row in self.types
        {
            let current:Int = type.depth
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
                    html.open(.ul) { $0.class = i == 0 ? "typetree" : nil }
                }
            }

            depth = current

            html[.li]
            {
                let uri:URI = Site.Docs[self.inliner.zones.principal, type.shoot]

                $0[.a] { $0.href = "\(uri)" } = type.top ?
                    type.shoot.stem.name :
                    type.shoot.stem.last
            }
        }
        for _:Int in 0 ..< depth
        {
            html.close(.ul)
        }
    }
}
