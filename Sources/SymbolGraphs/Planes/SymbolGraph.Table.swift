import BSON

extension SymbolGraph {
    @frozen public struct Table<Type, Element> where Type: PlaneType {
        @usableFromInline internal var storage: TableStorage<Element>

        @inlinable internal init(storage: TableStorage<Element> = []) {
            self.storage = storage
        }
    }
}
extension SymbolGraph.Table {
    @inlinable public init(viewing elements: [Element]) {
        self.init(storage: .init(elements: elements))
    }
}
extension SymbolGraph.Table: ExpressibleByArrayLiteral {
    @inlinable public init(arrayLiteral: Element...) {
        self.init(viewing: arrayLiteral)
    }
}
extension SymbolGraph.Table: Equatable where Element: Equatable {
}
extension SymbolGraph.Table: Hashable where Element: Hashable {
}
extension SymbolGraph.Table: Sendable where Element: Sendable {
}
extension SymbolGraph.Table {
    @inlinable public mutating func reserveCapacity(_ capacity: Int) {
        self.storage.reserveCapacity(capacity)
    }
    @inlinable public mutating func append(_ element: Element) -> Int32 {
        Type.plane | self.storage.append(element)
    }

    @inlinable public func map<T>(
        _ transform: (_ address: Int32, _ element: Element) throws -> T
    ) rethrows -> SymbolGraph.Table<Type, T> {
        .init(viewing: try self.indices.map { try transform($0, self[$0]) })
    }

    @inlinable public init(repeating element: Element, count: Int) {
        self.init(viewing: .init(repeating: element, count: count))
    }
}
extension SymbolGraph.Table: Sequence {
    @inlinable public func withContiguousStorageIfAvailable<Success>(
        _ body: (UnsafeBufferPointer<Element>) throws -> Success
    ) rethrows -> Success? {
        try self.storage.withContiguousStorageIfAvailable(body)
    }
    @inlinable public var underestimatedCount: Int {
        self.storage.count
    }
}
extension SymbolGraph.Table: RandomAccessCollection {
    @_semantics("array.get_count")
    @inlinable public var count: Int {
        self.storage.count
    }

    @inlinable public var startIndex: Int32 {
        Type.plane | self.storage.startIndex
    }
    @inlinable public var endIndex: Int32 {
        Type.plane | self.storage.endIndex
    }

    @_semantics("array.subscript")
    @inlinable public subscript(scalar: Int32) -> Element {
        _read {
            yield  self.storage[scalar & .significand]
        }
        _modify {
            yield &self.storage[scalar & .significand]
        }
    }
}
extension SymbolGraph.Table: BSONEncodable where Element: BSONEncodable {
    public func encode(to field: inout BSON.FieldEncoder) {
        self.storage.encode(to: &field)
    }
}
extension SymbolGraph.Table: BSONDecodable where Element: BSONDecodable {
    @inlinable public init(bson: BSON.AnyValue) throws {
        self.init(storage: try .init(bson: bson))
    }
}
