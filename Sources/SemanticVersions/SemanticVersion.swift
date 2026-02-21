@frozen public struct SemanticVersion: Equatable, Hashable, Sendable {
    public var number: PatchVersion
    public var suffix: Suffix

    @inlinable public init(number: PatchVersion, suffix: Suffix) {
        self.number = number
        self.suffix = suffix
    }
}
extension SemanticVersion {
    @inlinable public static func release(
        _ number: PatchVersion,
        build: String? = nil
    ) -> Self {
        .init(number: number, suffix: .release(build: build))
    }

    @inlinable public static func prerelease(
        _ number: PatchVersion,
        _ alpha: String,
        build: String? = nil
    ) -> Self {
        .init(number: number, suffix: .prerelease(alpha, build: build))
    }
}
extension SemanticVersion {
    /// Returns true if this is a release version, false if it is a prerelease.
    @inlinable public var release: Bool {
        switch self.suffix {
        case .release:      true
        case .prerelease:   false
        }
    }
}
extension SemanticVersion: CustomStringConvertible {
    @inlinable public var description: String {
        "\(self.number)\(self.suffix)"
    }
}
extension SemanticVersion: LosslessStringConvertible {
    @inlinable public init?(_ string: some StringProtocol) {
        var i: String.Index = string.endIndex
        let suffix: Suffix = .init(string, index: &i)

        guard
        let version: NumericVersion = .init(string[..<i]) else {
            return nil
        }

        self.init(number: .init(padding: version), suffix: suffix)
    }
}
// extension SemanticVersion:RawRepresentable
// {
//     @inlinable public
//     var rawValue:String
//     {
//         self.description
//     }
//     @inlinable public
//     init?(rawValue:String)
//     {
//         self.init(rawValue)
//     }
// }
extension SemanticVersion {
    /// Attempts to parse a semantic version from a tag string, such as `1.2.3` or
    /// `v1.2.3`. If the tag string has at least one, but fewer than three components,
    /// the semantic version is zero-extended.
    @inlinable public init?(refname: some StringProtocol) {
        if case "v"? = refname.first {
            self.init(refname.dropFirst())
        } else {
            self.init(refname)
        }
    }
}
