import UnidocAPI

extension Unidoc.Sitemap.Elements {
    @frozen public struct Iterator {
        @usableFromInline let bytes: ArraySlice<UInt8>
        @usableFromInline var index: Int

        @inlinable init(bytes: ArraySlice<UInt8>) {
            self.bytes = bytes
            self.index = bytes.startIndex
        }
    }
}
extension Unidoc.Sitemap.Elements.Iterator: IteratorProtocol {
    @inlinable public mutating func next() -> Unidoc.Shoot? {
        guard
        let i: Int = self.bytes[self.index...].firstIndex(
            of: Unidoc.Sitemap.Elements.separator
        ) else {
            return nil
        }
        defer {
            self.index = self.bytes.index(after: i)
        }

        return .init(from: self.bytes[self.index ..< i])
    }
}
