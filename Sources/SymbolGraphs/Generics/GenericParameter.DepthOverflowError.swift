import Signatures

extension GenericParameter {
    public struct DepthOverflowError: Error, Equatable, Sendable {
        public let expression: String

        public init(expression: String) {
            self.expression = expression
        }
    }
}
