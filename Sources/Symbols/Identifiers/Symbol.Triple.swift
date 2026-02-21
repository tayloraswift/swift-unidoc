extension Symbol {
    /// A pathetic imitation of
    /// https://github.com/apple/swift-driver/blob/main/Sources/SwiftDriver/Utilities/Triple.swift
    @frozen public struct Triple: Equatable, Hashable, Sendable {
        public let architecture: Architecture
        public let vendor: Vendor
        public let os: OS
        public var tail: String?

        @inlinable public init(
            architecture: Architecture,
            vendor: Vendor,
            os: OS,
            tail: String? = nil
        ) {
            self.architecture = architecture
            self.vendor = vendor
            self.os = os
            self.tail = tail
        }
    }
}
extension Symbol.Triple {
    @inlinable public static var arm64_apple_macosx14_0: Self {
        .init(architecture: "arm64", vendor: "apple", os: .macosx14_0)
    }

    @inlinable public static var arm64_apple_macosx15_0: Self {
        .init(architecture: "arm64", vendor: "apple", os: .macosx15_0)
    }

    @inlinable public static var aarch64_unknown_linux_gnu: Self {
        .init(architecture: "aarch64", vendor: "unknown", os: .linux, tail: "gnu")
    }

    @inlinable public static var x86_64_unknown_linux_gnu: Self {
        .init(architecture: .x86_64, vendor: "unknown", os: .linux, tail: "gnu")
    }
}
extension Symbol.Triple: CustomStringConvertible {
    @inlinable public var description: String {
        self.tail.map {
            "\(self.architecture)-\(self.vendor)-\(self.os)-\($0)"
        } ?? "\(self.architecture)-\(self.vendor)-\(self.os)"
    }
}
extension Symbol.Triple: LosslessStringConvertible {
    @inlinable public init?(_ string: String) {
        self.init(string[...])
    }
    @inlinable public init?(_ string: Substring) {
        let start: (Never, String.Index, String.Index, String.Index)

        guard
        let i: String.Index = string.firstIndex(of: "-") else {
            return nil
        }

        start.1 = string.index(after: i)

        guard
        let j: String.Index = string[start.1...].firstIndex(of: "-") else {
            return nil
        }

        start.2 = string.index(after: j)

        let architecture: String = .init(string[..<i])
        let vendor: String = .init(string[start.1 ..< j])
        let os: String
        let tail: String?

        if  let k: String.Index = string[start.2...].firstIndex(of: "-") {
            os = .init(string[start.2 ..< k])
            start.3 = string.index(after: k)
            tail = .init(string[start.3...])
        } else {
            os = .init(string[start.2...])
            tail = nil
        }

        self.init(
            architecture: .init(name: architecture),
            vendor: .init(name: vendor),
            os: .init(name: os),
            tail: tail
        )
    }
}
