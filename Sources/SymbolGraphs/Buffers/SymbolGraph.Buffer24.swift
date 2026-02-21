import BSON

extension SymbolGraph {
    /// A type that can serialize an array of ``SymbolGraph.DeclPlane`` scalars
    /// much more compactly than a native BSON list.
    ///
    /// Empirically, this type reduces symbol graph archive size by around
    /// 3 to 8 percent.
    @frozen @usableFromInline struct Buffer24: Equatable, Sendable {
        @usableFromInline var elements: [Int32]

        @inlinable init(_ elements: [Int32]) {
            self.elements = elements
        }
    }
}
extension SymbolGraph.Buffer24 {
    @inlinable init?(elidingEmpty elements: [Int32]) {
        if  elements.isEmpty {
            return nil
        } else {
            self.init(elements)
        }
    }
}

extension SymbolGraph.Buffer24: BSONArrayEncodable, RandomAccessCollection {
    @inlinable var startIndex: Int { self.elements.startIndex }

    @inlinable var endIndex: Int { self.elements.endIndex }

    @inlinable subscript(position: Int) -> Element { .init(int32: self.elements[position]) }
}
extension SymbolGraph.Buffer24: BSONArrayDecodable {
    @inlinable init(from bson: borrowing BSON.BinaryArray<Element>) throws {
        self.init(bson.map(\.int32))
    }
}
