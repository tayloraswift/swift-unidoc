extension Pie {
    @frozen public struct Accumulator<Key> where Key: Hashable {
        @usableFromInline var counts: [Key: Int]

        @inlinable init(counts: [Key: Int]) {
            self.counts = counts
        }
    }
}
extension Pie.Accumulator: Sendable where Key: Sendable {
}
extension Pie.Accumulator: ExpressibleByDictionaryLiteral {
    @inlinable public init(dictionaryLiteral: (Key, Never)...) {
        self.init(counts: [:])
    }
}
extension Pie.Accumulator {
    @inlinable public func sum() -> Int { self.counts.values.reduce(0, +) }

    @inlinable public subscript(key: Key) -> Int {
        _read {
            yield  self.counts[key, default: 0]
        }
        _modify {
            yield &self.counts[key, default: 0]
        }
    }
}
extension Pie.Accumulator: Pie.ChartSource where Key: Comparable, Key: Pie.ChartKey {
    @inlinable public var sectors: [(key: Key, value: Int)] {
        self.counts.sorted { $0.key < $1.key }
    }
}
