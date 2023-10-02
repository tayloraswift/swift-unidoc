import HTML

@frozen public
struct Pie<Sector> where Sector:PieSector
{
    @usableFromInline internal
    var sectors:[Sector]
    @usableFromInline internal
    var total:Int

    @inlinable public
    init(sectors:[Sector])
    {
        self.sectors = sectors
        self.total = sectors.reduce(0) { $0 + $1.value }
    }
}
extension Pie
{
    @inlinable public mutating
    func append(_ sector:Sector)
    {
        self.sectors.append(sector)
        self.total += sector.value
    }
}
extension Pie
{
    @inlinable public
    var legend:Legend
    {
        .init(sectors: self.sectors, total: self.total)
    }
}
extension Pie:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Sector...)
    {
        self.init(sectors: arrayLiteral)
    }
}
extension Pie:HyperTextOutputStreamable
{
    @inlinable public static
    func += (html:inout HTML.ContentEncoder, self:Self)
    {
        html[.div, { $0.class = "pie-color" }]
        {
            $0[.svg] { $0.viewBox = "-1 -1 2 2" } = self
        }

        html[.div] { $0.class = "pie-geometry" }
    }
}
extension Pie:ScalableVectorOutputStreamable
{
    @inlinable public static
    func += (svg:inout SVG.ContentEncoder, self:Self)
    {
        guard let last:Int = self.sectors.indices.last
        else
        {
            return
        }

        svg[.g]
        {
            let divisor:Double = .init(self.total)

            var start:SVG.Point<Double> = .init(1, 0)
            var w:Int = 0

            for sector:Sector in self.sectors[..<last]
            {
                w += sector.value

                let f:Double = Double.init(w) / divisor
                let r:Double = 2 * Double.pi * f

                let share:Double = Double.init(sector.value) / divisor
                let slice:PieSlice = .init(share: share,
                    from: start,
                    to: r)

                $0[.path] { $0.d = slice.d ; $0.class = sector.class } = sector.title(share)

                start = slice.endArc
            }

            let sector:Sector = self.sectors[last]
            if  w > 0
            {
                let share:Double = Double.init(sector.value) / divisor
                let slice:PieSlice = .init(share: share,
                    startArc: start,
                    endArc: .init(1, 0),
                    end: 2 * Double.pi)

                $0[.path] { $0.d = slice.d ; $0.class = sector.class } = sector.title(share)
            }
            else
            {
                $0[.circle] { $0.r = "1" ; $0.class = sector.class } = sector.title(1.0)
                return
            }
        }
    }
}
