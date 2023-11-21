/// A type that can format a sector share with one decimal place.
@frozen public
struct PieShareFormat1F
{
    public
    let share:Double

    @inlinable public
    init(_ share:Double)
    {
        self.share = share
    }
}
extension PieShareFormat1F:PieShareFormat
{
    /// Formats the share as a percentage with one decimal place, without the percent sign.
    /// Returns nil if the share is less than 0.1 percent.
    public
    var formatted:String?
    {
        guard self.share >= 0.001
        else
        {
            return nil
        }

        let permille:Int = .init((self.share * 1000).rounded())
        let (percent, f):(Int, Int) = permille.quotientAndRemainder(
            dividingBy: 10)

        return "\(percent).\(f)"
    }
}
