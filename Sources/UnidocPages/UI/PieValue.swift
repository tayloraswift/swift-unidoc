import HTML

public
protocol PieValue
{
    var weight:Int { get }
    var `class`:String? { get }

    func label(share:Double) -> String
    func legend(_ html:inout HTML.ContentEncoder, share:Double)
}
extension PieValue
{
    func title(_ share:Double) -> PieSlice.Title
    {
        .init(self.label(share: share))
    }
}
