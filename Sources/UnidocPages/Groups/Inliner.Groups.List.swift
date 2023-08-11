import HTML
import Unidoc

extension Inliner.Groups
{
    struct List
    {
        let inliner:Inliner

        let heading:String?
        let scalars:[Unidoc.Scalar]

        init(_ inliner:Inliner, heading:String?, scalars:[Unidoc.Scalar])
        {
            self.inliner = inliner
            self.heading = heading
            self.scalars = scalars
        }
    }
}
extension Inliner.Groups.List:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        if  let heading:String = self.heading
        {
            html[.h3] = heading
        }
        html[.ul]
        {
            for scalar:Unidoc.Scalar in self.scalars
            {
                $0 ?= self.inliner.card(scalar)
            }
        }
    }
}
