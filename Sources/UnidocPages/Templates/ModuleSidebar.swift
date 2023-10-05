import HTML
import UnidocRecords
import URI

struct ModuleSidebar
{
    private
    let inliner:VersionedPageContext

    let nouns:[Volume.Noun]

    init(_ inliner:VersionedPageContext, nouns:[Volume.Noun])
    {
        self.inliner = inliner

        self.nouns = nouns
    }
}
extension ModuleSidebar:HyperTextOutputStreamable
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

                var uri:URI { Site.Docs[self.inliner.volumes.principal, noun.shoot] }
                let name:Substring = noun.shoot.stem.last

                //  The URI is only valid if the principal volume API version is at least 1.0!
                if  case .foreign = noun.from, self.inliner.volumes.principal.api < .v(1, 0)
                {
                    $0[.span] = name
                }
                else
                {
                    $0[.a]
                    {
                        $0.href = "\(uri)"

                        switch noun.from
                        {
                        case .culture:  break
                        case .package:  $0.class = "extension local"
                        case .foreign:  $0.class = "extension foreign"
                        }

                    } = name
                }

            }
            for _:Int in 1 ..< depth
            {
                $0.close(.div)
            }
        }
    }
}
