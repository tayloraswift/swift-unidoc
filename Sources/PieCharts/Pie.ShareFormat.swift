extension Pie {
    /// A type that can format a sector share as a percentage, without the percent sign.
    public protocol ShareFormat: ExpressibleByFloatLiteral, CustomStringConvertible {
        init(_ share: Double)

        /// Formats this share as a percentage, without the percent sign. Returns nil if
        /// the share is less than some custom-defined threshold.
        var formatted: String? { get }

        /// Formats this share as a percentage, without the percent sign.
        var description: String { get }
    }
}
extension Pie.ShareFormat {
    @inlinable public init(floatLiteral: Double) {
        self.init(floatLiteral)
    }

    @inlinable public var description: String { self.formatted ?? "0" }
}
