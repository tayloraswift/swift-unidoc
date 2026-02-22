import Symbols
import TraceableErrors

extension SSGC.TypeChecker {
    public struct CultureError: Error, Sendable {
        public let underlying: any Error
        public let culture: Symbol.Module

        public init(underlying: any Error, culture: Symbol.Module) {
            self.underlying = underlying
            self.culture = culture
        }
    }
}
extension SSGC.TypeChecker.CultureError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.culture == rhs.culture && lhs.underlying == rhs.underlying
    }
}
extension SSGC.TypeChecker.CultureError: TraceableError {
    public var notes: [String] {
        ["While compiling culture '\(self.culture)'."]
    }
}
