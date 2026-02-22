import UnidocRecords

extension Unidoc.UserSession {
    @frozen public struct Web: Equatable, Hashable, Sendable {
        public let id: Unidoc.Account
        public let cookie: Int64
        public let symbol: String

        @inlinable public init(id: Unidoc.Account, cookie: Int64, symbol: String) {
            self.id = id
            self.cookie = cookie
            self.symbol = symbol
        }
    }
}
extension Unidoc.UserSession.Web: CustomStringConvertible {
    @inlinable public var description: String {
        let hex: String = .init(
            UInt64.init(bitPattern: self.cookie),
            radix: 16,
            uppercase: true
        )

        return "\(self.id)_\(hex)$\(self.symbol)"
    }
}
extension Unidoc.UserSession.Web: LosslessStringConvertible {
    @inlinable public init?(_ string: some StringProtocol) {
        guard
        let i: String.Index = string.firstIndex(of: "_"),
        let account: Unidoc.Account = .init(string[..<i]) else {
            return nil
        }

        let cookie: String.Index = string.index(after: i)

        guard
        let j: String.Index = string[cookie...].firstIndex(of: "$") else {
            return nil
        }

        guard
        let cookie: UInt64 = .init(string[cookie ..< j], radix: 16) else {
            return nil
        }

        //  Symbol is likely short enough to benefit from small string optimization.
        self.init(
            id: account,
            cookie: Int64.init(bitPattern: cookie),
            symbol: String.init(string[string.index(after: j)...])
        )
    }
}
