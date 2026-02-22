import HTML

extension Pie {
    public protocol ChartSource<Key, Sectors> {
        associatedtype Sectors: Sequence<(key: Key, value: Int)>
        associatedtype Key: ChartKey

        var sectors: Sectors { get }
    }
}
extension Pie.ChartSource {
    @inlinable public func chart(
        title: (Key, Key.ShareFormat) throws -> String
    ) rethrows -> Pie.Chart<Key> {
        .init(shape: try self.shape(title: title))
    }

    @inlinable public func disc(
        title: (Key, Key.ShareFormat) throws -> String
    ) rethrows -> Pie.Disc<Key> {
        .init(shape: try self.shape(title: title))
    }

    @inlinable func shape(
        title: (Key, Key.ShareFormat) throws -> String
    ) rethrows -> Pie.Shape<Key> {
        let sectors: [(key: Key, value: Int)] = self.sectors.filter { $0.value > 0 }

        guard sectors.startIndex < sectors.endIndex else {
            return .slices([])
        }

        let divisor: Double = .init(sectors.reduce(into: 0) { $0 += $1.value })
        let last: Int = sectors.index(before: sectors.endIndex)

        var start: SVG.Point<Double> = .init(1, 0)
        var w: Int = 0

        var slices: [Pie.Shape<Key>.Slice] = []
        slices.reserveCapacity(sectors.count)

        for (key, value): (Key, Int) in sectors[..<last] {
            w += value

            let f: Double = Double.init(w) / divisor
            let r: Double = 2 * Double.pi * f

            let share: Double = Double.init(value) / divisor
            let slice: Pie.Shape<Key>.Slice = .init(
                geometry: .init(
                    share: share,
                    from: start,
                    to: r
                ),
                title: try title(key, .init(share)),
                key: key
            )

            start = slice.geometry.endArc
            slices.append(slice)
        }

        let (key, value): (Key, Int) = sectors[last]

        if  w > 0 {
            let share: Double = Double.init(value) / divisor
            let slice: Pie.Shape<Key>.Slice = .init(
                geometry: .init(
                    share: share,
                    startArc: start,
                    endArc: .init(1, 0),
                    end: 2 * Double.pi
                ),
                title: try title(key, .init(share)),
                key: key
            )

            slices.append(slice)
            return .slices(slices)
        } else {
            return .circle(key, try title(key, 1.0))
        }
    }
}
