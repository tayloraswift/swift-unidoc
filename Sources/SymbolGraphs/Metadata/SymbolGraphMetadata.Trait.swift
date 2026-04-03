import BSON

extension SymbolGraphMetadata {
    @frozen public struct Trait: Equatable, Hashable, Sendable {
        public let id: String

        @inlinable internal init(id: String) {
            self.id = id
        }
    }
}
extension SymbolGraphMetadata.Trait: CustomStringConvertible {
    @inlinable public var description: String { self.id }
}
extension SymbolGraphMetadata.Trait: LosslessStringConvertible {
    @inlinable public init(_ id: String) { self.init(id: id) }
}
extension SymbolGraphMetadata.Trait: BSONStringDecodable, BSONStringEncodable {}
