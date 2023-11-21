import HTML

public
protocol PieValues<Sectors, SectorKey>
{
    associatedtype SectorKey:PieSectorKey
    associatedtype Sectors:BidirectionalCollection<(key:SectorKey, value:Int)>

    var sectors:Sectors { get }
}
extension PieValues
{
    @inlinable public
    func chart(title:(SectorKey, SectorKey.ShareFormat) throws -> String)
        rethrows -> Pie<SectorKey>.Chart
    {
        let pie:Pie<SectorKey> = try self.pie(title: title)
        return .init(shape: pie.shape)
    }

    @inlinable public
    func pie(title:(SectorKey, SectorKey.ShareFormat) throws -> String)
        rethrows -> Pie<SectorKey>
    {
        let sectors:Sectors = self.sectors

        guard sectors.startIndex < sectors.endIndex
        else
        {
            return .init(shape: .slices([]))
        }

        let divisor:Double = .init(sectors.reduce(into: 0) { $0 += $1.value })
        let last:Sectors.Index = sectors.index(before: sectors.endIndex)

        var start:SVG.Point<Double> = .init(1, 0)
        var w:Int = 0

        var slices:[Pie<SectorKey>.Slice] = []
            slices.reserveCapacity(sectors.count)

        for (key, value):(SectorKey, Int) in sectors[..<last] where value > 0
        {
            w += value

            let f:Double = Double.init(w) / divisor
            let r:Double = 2 * Double.pi * f

            let share:Double = Double.init(value) / divisor
            let slice:Pie<SectorKey>.Slice = .init(geometry: .init(share: share,
                    from: start,
                    to: r),
                title: .init(try title(key, .init(share))),
                key: key)

            start = slice.geometry.endArc
            slices.append(slice)
        }

        let (key, value):(SectorKey, Int) = sectors[last]
        if  value > 0,
            w > 0
        {
            let share:Double = Double.init(value) / divisor
            let slice:Pie<SectorKey>.Slice = .init(geometry: .init(share: share,
                    startArc: start,
                    endArc: .init(1, 0),
                    end: 2 * Double.pi),
                title: .init(try title(key, .init(share))),
                key: key)

            slices.append(slice)
            return .init(shape: .slices(slices))
        }
        else
        {
            return .init(shape: .circle(key, .init(try title(key, 1.0))))
        }
    }
}
