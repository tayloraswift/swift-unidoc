@frozen public enum InlineArray<Element> {
    case one  (Element)
    case some([Element])
}
extension InlineArray: ExpressibleByArrayLiteral {
    @inlinable public init(arrayLiteral: Element...) {
        self = arrayLiteral.count == 1 ? .one(arrayLiteral[0]) : .some(arrayLiteral)
    }
}
extension InlineArray: Equatable where Element: Equatable {
}
extension InlineArray: Hashable where Element: Hashable {
}
extension InlineArray: Sendable where Element: Sendable {
}
extension InlineArray: Sequence {
    @inlinable public func withContiguousStorageIfAvailable<T>(
        _ body: (UnsafeBufferPointer<Element>) throws -> T
    ) rethrows -> T? {
        switch self {
        case .one(let element):
            try withUnsafePointer(to: element) { try body(.init(start: $0, count: 1)) }
        case .some(let elements):
            try elements.withContiguousStorageIfAvailable(body)
        }
    }
    @inlinable public var underestimatedCount: Int {
        self.count
    }
}
extension InlineArray: MutableCollection {
}
extension InlineArray: RandomAccessCollection {
    @inlinable public var startIndex: Int {
        switch self {
        case .one:                  0
        case .some(let elements):   elements.startIndex
        }
    }
    @inlinable public var endIndex: Int {
        switch self {
        case .one:                  1
        case .some(let elements):   elements.endIndex
        }
    }
    @inlinable public subscript(index: Int) -> Element {
        _read {
            switch self {
            case .one(let element):
                precondition(index == 0)
                yield element

            case .some(let elements):
                yield elements[index]
            }
        }
        _modify {
            switch self {
            case .one(var element):
                precondition(index == 0)
                self = .some([])
                defer { self = .one(element) }
                yield &element

            case .some(var elements):
                self = .some([])
                defer { self = .some(elements) }
                yield &elements[index]
            }
        }
    }
}
extension InlineArray {
    @inlinable public mutating func append(_ element: __owned Element) {
        switch self {
        case .one(let first):
            self = .some([first, element])

        case .some(var elements):
            if  elements.isEmpty {
                self = .one(element)
            } else {
                self = .some([])
                elements.append(element)
                self = .some(elements)
            }
        }
    }
}
