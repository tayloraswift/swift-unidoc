import HTML

@frozen @usableFromInline internal
struct PieSlice
{
    @usableFromInline internal
    let share:Double
    @usableFromInline internal
    let startArc:SVG.Point<Double>
    @usableFromInline internal
    let endArc:SVG.Point<Double>
    /// The end of the slice, in radians.
    @usableFromInline internal
    let end:Double

    @inlinable internal
    init(share:Double,
        startArc:SVG.Point<Double>,
        endArc:SVG.Point<Double>,
        end:Double)
    {
        self.share = share
        self.startArc = startArc
        self.endArc = endArc
        self.end = end
    }
}
extension PieSlice
{
    @inlinable internal
    init(share:Double, from start:SVG.Point<Double>, to end:Double)
    {
        self.init(share: share,
            startArc: start,
            endArc: .init(radians: end),
            end: end)
    }
}
extension PieSlice
{
    @usableFromInline internal
    var d:String
    {
        var d:String = "M 0,0 L \(self.startArc)"
        switch self.share
        {
        case 0 ..< 0.375:
            d += " A 1,1 0 0 0 \(self.endArc)"

        case 0.625 ... 1:
            d += " A 1,1 0 1 0 \(self.endArc)"

        case _:
            //  Near-semicircular arc; split into 2 segments to avoid degenerate behavior.
            let p:SVG.Point<Double> = .init(radians: self.end - 0.5 * Double.pi)
            d += " A 1,1 0 0 0 \(p) A 1,1 0 0 0 \(self.endArc)"
        }

        if  self.endArc.x >= 0,
            self.endArc.y == 0
        {
            d += " Z"
        }
        else if
            self.endArc.x >= 0,
            self.endArc.y >= 0
        {
            var fringe:SVG.Point<Double> = .init(radians: self.end + 0.1, radius: 0.5)
                fringe.y = max(fringe.y, 0)

            d += " L \(fringe) Z"
        }
        else
        {
            let fringe:SVG.Point<Double> = .init(radians: self.end + 0.1, radius: 0.5)
            d += " L \(fringe) Z"
        }

        return d
    }
}
