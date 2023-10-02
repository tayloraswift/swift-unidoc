import HTML

public
protocol PieSector
{
    var `class`:String? { get }
    var  value:Int { get }

    /// Formats the share as a percentage, without the percent sign.
    static
    func format(share:Double) -> String

    /// Returns a tooltip to show when hovering over the sector.
    func label(share:Double) -> String
    /// Conditionally renders the legend key for this sector.
    func legend(_ html:inout HTML.ContentEncoder, share:Double)
}
extension PieSector where Self:Identifiable, ID:CustomStringConvertible
{
    /// Renders the legend key for this sector if the share is greater than 0.1 percent.
    /// The instance’s ``id`` is used for the display text.
    @inlinable public
    func legend(_ html:inout HTML.ContentEncoder, share:Double)
    {
        if  share < 0.001
        {
            return
        }

        html[.dt] { $0.class = self.class } = "\(self.id)"
        html[.dd] = "\(Self.format(share: share))%"
    }
}
extension PieSector
{
    /// Formats the share as a percentage with one decimal place, without the percent sign.
    @inlinable public static
    func format(share:Double) -> String
    {
        let permille:Int = .init((share * 1000).rounded())
        let (percent, f):(Int, Int) = permille.quotientAndRemainder(
            dividingBy: 10)

        return "\(percent).\(f)"
    }

    @inlinable internal
    func title(_ share:Double) -> PieSlice.Title
    {
        .init(self.label(share: share))
    }
}
