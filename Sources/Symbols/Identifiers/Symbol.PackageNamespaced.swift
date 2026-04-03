extension Symbol {
    public protocol PackageNamespaced: Identifiable, Equatable, Hashable, Comparable, Sendable {
        var package: Package { get }
        var name: String { get }
        init(package: Package, name: String)
    }
}

extension Symbol.PackageNamespaced {
    @inlinable public static func < (a: Self, b: Self) -> Bool {
        (a.package, a.name) < (b.package, b.name)
    }
}
extension Symbol.PackageNamespaced {
    /// Returns `self`.
    @inlinable public var id: Self { self }
}
extension Symbol.PackageNamespaced where Self: CustomStringConvertible {
    public var description: String {
        "\(self.package):\(self.name)"
    }
}
extension Symbol.PackageNamespaced where Self: LosslessStringConvertible {
    @inlinable public init?(_ string: borrowing some StringProtocol) {
        if  let colon: String.Index = string.firstIndex(of: ":") {
            self.init(
                package: .init(string[..<colon]),
                name: .init(string[string.index(after: colon)...]),
            )
        } else {
            return nil
        }
    }
}
