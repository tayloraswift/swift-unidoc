import HTML

extension StatsBreakdown
{
    struct Condensed
    {
        private
        let unweighted:Pie<Stat>
        private
        let weighted:Pie<Stat>

        init(unweighted:Pie<Stat>, weighted:Pie<Stat>)
        {
            self.unweighted = unweighted
            self.weighted = weighted
        }
    }
}
extension StatsBreakdown.Condensed:HyperTextOutputStreamable
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
