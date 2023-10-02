import HTML
import Unidoc
import UnidocProfiling

extension Unidoc.StatsBreakdown
{
    struct Condensed
    {
        private
        let unweighted:Pie<Unidoc.Stat>
        private
        let weighted:Pie<Unidoc.Stat>

        init(unweighted:Pie<Unidoc.Stat>, weighted:Pie<Unidoc.Stat>)
        {
            self.unweighted = unweighted
            self.weighted = weighted
        }
    }
}
extension Unidoc.StatsBreakdown.Condensed:HyperTextOutputStreamable
{
    static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.h3] = "Declarations"
        html[.figure]
        {
            $0[.div] { $0.class = "pie" } = self.unweighted
        }

        html[.h3] = "Symbols"
        html[.figure]
        {
            $0[.div] { $0.class = "pie" } = self.weighted
        }
    }
}
