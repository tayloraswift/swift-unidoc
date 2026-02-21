@frozen public struct MultipartView {
    @usableFromInline let message: [UInt8]
    @usableFromInline private(set) var parts: [Range<Int>]

    public init(splitting message: [UInt8], on boundary: String) throws {
        let preamble: [UInt8] =              [0x2D, 0x2D] + boundary.utf8
        let separator: [UInt8] = [0x0D, 0x0A, 0x2D, 0x2D] + boundary.utf8

        self.message = message
        self.parts = []

        guard   var start: Int = self.message.index(
            after: self.message.startIndex,
            skipping: preamble
        ) else {
            throw MultipartSplitError.invalidPreamble
        }

        if  let index: Int = self.message.index(after: start, skipping: [0x0D, 0x0A]) {
            start = index
        } else if self.message[start...].starts(with: [0x2D, 0x2D]) {
            return // Empty form
        } else {
            throw MultipartSplitError.invalidPreamble
        }

        var index: Int = start
        while index < self.message.endIndex {
            // we cannot re-use index advancements, because a boundary can start
            // after a prefix of itself
            guard let next: Int = self.message.index(after: index, skipping: separator) else {
                self.message.formIndex(after: &index)
                continue
            }

            self.parts.append(start ..< index)

            if  let next: Int = self.message.index(after: next, skipping: [0x0D, 0x0A]) {
                start = next
                index = next
            } else if self.message[next...].starts(with: [0x2D, 0x2D]) {
                return
            }
        }
        throw MultipartSplitError.invalidBoundary
    }
}
extension MultipartView: RandomAccessCollection {
    @inlinable public var startIndex: Int {
        self.parts.startIndex
    }
    @inlinable public var endIndex: Int {
        self.parts.endIndex
    }
    @inlinable public subscript(index: Int) -> ArraySlice<UInt8> {
        self.message[self.parts[index]]
    }
}
