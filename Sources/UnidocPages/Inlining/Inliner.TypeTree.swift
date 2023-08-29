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

        let nouns:[Volume.Noun]

        init(_ inliner:Inliner, nouns:[Volume.Noun])
        {
            self.inliner = inliner

            self.nouns = nouns
        }
    }
}
extension Inliner.TypeTree:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        //  Unfortunately, this cannot be a proper `ul`, because `ul` cannot contain another
        //  `ul` as a direct child.
        html[.div, { $0.class = "nountree" }]
        {
            var depth:Int = 1

            for noun:Volume.Noun in self.nouns
            {
                let current:Int = max(1, noun.shoot.stem.depth)
                if  current < depth
                {
                    for _:Int in current ..< depth
                    {
                        $0.close(.div)
                    }
                }
                else
                {
                    for _:Int in depth ..< current
                    {
                        $0.open(.div) { $0.class = "indent" }
                    }
                }

                depth = current

                //  The URI is only correct if the noun is a citizen in the principal zone!
                var uri:URI { Site.Docs[self.inliner.names.principal, noun.shoot] }
                let name:Substring = noun.shoot.stem.last

                switch noun.same
                {
                case nil:       $0[.span] = name
                case .culture?: $0[.a] { $0.href = "\(uri)" } = name
                case .package?: $0[.a] { $0.href = "\(uri)" ; $0.class = "extension" } = name
                }
            }
            for _:Int in 1 ..< depth
            {
                $0.close(.div)
            }
        }
    }
}
