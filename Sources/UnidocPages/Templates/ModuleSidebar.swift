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
            var outer:Volume.Stem = ""

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
                defer
                {
                    depth = current
                    outer = noun.shoot.stem
                }

                var uri:URI { Site.Docs[self.inliner.volumes.principal, noun.shoot] }

                switch noun.style
                {
                case .text(let text):
                    $0[.a] { $0.href = "\(uri)" ; $0.class = "text" } = text

                case .stem(let citizenship):
                    let name:Substring = noun.shoot.stem.trimming(scope: outer) ??
                        noun.shoot.stem.name
                    //  The URI is only valid if the principal volume API version is at
                    //  least 1.0!
                    if  case .foreign = citizenship,
                        self.inliner.volumes.principal.api < .v(1, 0)
                    {
                        $0[.span] = name
                    }
                    else
                    {
                        $0[.a]
                        {
                            $0.href = "\(uri)"

                            switch citizenship
                            {
                            case .culture:  break
                            case .package:  $0.class = "extension local"
                            case .foreign:  $0.class = "extension foreign"
                            }

                        } = name
                    }
                }
            }
            for _:Int in 1 ..< depth
            {
                $0.close(.div)
            }
        }
    }
}
