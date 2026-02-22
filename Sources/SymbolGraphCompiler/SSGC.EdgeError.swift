import SymbolGraphParts
import Symbols
import TraceableErrors

extension SSGC {
    public struct EdgeError<Relationship>: Error,
        Sendable where Relationship: SymbolRelationship {
        public let relationship: Relationship
        public let underlying: any Error

        public init(underlying: any Error, in relationship: Relationship) {
            self.underlying = underlying
            self.relationship = relationship
        }
    }
}
extension SSGC.EdgeError: TraceableError {
    public var notes: [String] {
        ["While validating relationship \(self.relationship)"]
    }
}
