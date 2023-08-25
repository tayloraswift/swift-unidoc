import HTML

extension StatsBreakdown
{
    struct Stat:Sendable
    {
        let stratum:String
        let state:String
        let value:Int
        let `class`:String?

        init(stratum:String, state:String, value:Int, `class`:String? = nil)
        {
            self.stratum = stratum
            self.state = state
            self.value = value
            self.class = `class`
        }
    }
}
extension StatsBreakdown.Stat
{
    private static
    func format(share:Double) -> String
    {
        let permille:Int = .init((share * 1000).rounded())
        let (percent, f):(Int, Int) = permille.quotientAndRemainder(
            dividingBy: 10)

        return "\(percent).\(f)"
    }
}
extension StatsBreakdown.Stat:PieSector
{
    func legend(_ html:inout HTML.ContentEncoder, share:Double)
    {
        if  share < 0.001
        {
            return
        }

        html[.dt] { $0.class = self.class } = "\(self.state)"
        html[.dd] = "\(Self.format(share: share))%"
    }

    func label(share:Double) -> String
    {
        """
        \(Self.format(share: share)) percent of the \(self.stratum) are \(self.state)
        """
    }
}
