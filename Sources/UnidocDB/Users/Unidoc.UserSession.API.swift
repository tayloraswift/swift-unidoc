import UnidocRecords

extension Unidoc.UserSession {
    @frozen public struct API: Equatable, Hashable, Sendable {
        public let id: Unidoc.Account
        public let apiKey: Int64

        @inlinable public init(id: Unidoc.Account, apiKey: Int64) {
            self.id = id
            self.apiKey = apiKey
        }
    }
}
extension Unidoc.UserSession.API: CustomStringConvertible {
    @inlinable public var description: String {
        "\(self.id)_\(String.init(UInt64.init(bitPattern: self.apiKey), radix: 16))"
    }
}
extension Unidoc.UserSession.API: LosslessStringConvertible {
    @inlinable public init?(_ string: some StringProtocol) {
        guard
        let separator: String.Index = string.firstIndex(of: "_"),
        let id: Unidoc.Account = .init(string[..<separator]),
        let apiKey: UInt64 = .init(string[string.index(after: separator)...], radix: 16) else {
            return nil
        }

        self.init(id: id, apiKey: .init(bitPattern: apiKey))
    }
}
