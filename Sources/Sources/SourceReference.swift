@frozen public struct SourceReference<Frame> {
    public let frame: Frame
    public let range: Range<SourcePosition>?

    @inlinable public init(range: Range<SourcePosition>?, in frame: Frame) {
        self.range = range
        self.frame = frame
    }
}
extension SourceReference: Equatable where Frame: Equatable {
}
extension SourceReference: Hashable where Frame: Hashable {
}
extension SourceReference: Sendable where Frame: Sendable {
}
extension SourceReference {
    @inlinable public func map<T>(
        _ transform: (Frame) throws -> T
    ) rethrows -> SourceReference<T> {
        .init(range: self.range, in: try transform(self.frame))
    }
}
