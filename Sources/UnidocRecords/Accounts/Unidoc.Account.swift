import BSON

extension Unidoc {
    @frozen public struct Account: Equatable, Hashable, Sendable {
        public let type: Unidoc.AccountType
        @usableFromInline let user: UInt32

        @inlinable public init(type: Unidoc.AccountType, user: UInt32) {
            self.type = type
            self.user = user
        }
    }
}
extension Unidoc.Account {
    @inlinable init?(bits: UInt64) {
        guard
        let type: Unidoc.AccountType = .init(rawValue: bits >> 32) else {
            return nil
        }

        self.init(type: type, user: UInt32.init(truncatingIfNeeded: bits))
    }

    @inlinable var bits: UInt64 {
        self.type.rawValue << 32 | UInt64.init(self.user)
    }

    @inlinable public var github: UInt32? {
        guard
        self.type == .github else {
            return nil
        }

        return self.user
    }
}
extension Unidoc.Account: RawRepresentable {
    @inlinable public init?(rawValue: Int64) { self.init(bits: .init(bitPattern: rawValue)) }

    @inlinable public var rawValue: Int64 { .init(bitPattern: self.bits) }
}
extension Unidoc.Account: BSONDecodable, BSONEncodable {
}
extension Unidoc.Account: CustomStringConvertible {
    @inlinable public var description: String { "\(self.bits)" }
}
extension Unidoc.Account: LosslessStringConvertible {
    @inlinable public init?(_ description: some StringProtocol) {
        if  let value: UInt64 = .init(description),
            let value: Self = .init(bits: value) {
            self = value
        } else {
            return nil
        }
    }
}
