import Signatures

extension GenericConstraint {
    public struct SigilError: Error, Equatable, Sendable {
        public let codepoint: Unicode.Scalar?

        public init(invalid codepoint: Unicode.Scalar? = nil) {
            self.codepoint = codepoint
        }
    }
}
extension GenericConstraint.SigilError: CustomStringConvertible {
    public var description: String {
        self.codepoint.map {
            "Invalid constraint sigil '\($0)'."
        } ?? "Missing constraint sigil."
    }
}
