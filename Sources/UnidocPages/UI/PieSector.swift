import HTML

public
protocol PieSector
{
    var `class`:String? { get }
    var  value:Int { get }

    func label(share:Double) -> String
    func legend(_ html:inout HTML.ContentEncoder, share:Double)
}
extension PieSector
{
    func title(_ share:Double) -> PieSlice.Title
    {
        .init(self.label(share: share))
    }
}
