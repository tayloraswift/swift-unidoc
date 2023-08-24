import HTML

@frozen public
struct Pie
{
    public
    var values:[Value]

    @inlinable public
    init(values:[Value])
    {
        self.values = values
    }
}
extension Pie:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Value...)
    {
        self.init(values: arrayLiteral)
    }
}
extension Pie:HyperTextOutputStreamable
{
    public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.div, { $0.class = "pie" }]
        {
            $0[.div, { $0.class = "pie-color" }]
            {
                $0[.svg] { $0.viewBox = "-1 -1 2 2" } = self
            }

            $0[.div] { $0.class = "pie-geometry" }
        }
    }
}
extension Pie:ScalableVectorOutputStreamable
{
    public static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        guard let last:Int = self.values.indices.last
        else
        {
            return
        }

        svg[.g]
        {
            let divisor:Double = .init(self.values.reduce(0) { $0 + $1.weight })

            var start:SVG.Point<Double> = .init(1, 0)
            var w:Int = 0

            for value:Value in self.values[..<last]
            {
                w += value.weight

                let f:Double = Double.init(w) / divisor
                let r:Double = 2 * Double.pi * f

                let share:Double = Double.init(value.weight) / divisor
                let slice:Slice = .init(share: share,
                    from: start,
                    to: r)

                $0[.path] { $0.d = slice.d ; $0.class = value.class } = value.title(share)

                start = slice.endArc
            }

            let value:Value = self.values[last]
            if  w > 0
            {
                let share:Double = Double.init(value.weight) / divisor
                let slice:Slice = .init(share: share,
                    startArc: start,
                    endArc: .init(1, 0),
                    end: 2 * Double.pi)

                $0[.path] { $0.d = slice.d ; $0.class = value.class } = value.title(share)
            }
            else
            {
                $0[.circle] { $0.r = "1" ; $0.class = value.class } = value.title(1.0)
                return
            }
        }
    }
}
