extension Phylum.Decl {
    @frozen public struct Route: Equatable, Hashable, Sendable {
        @usableFromInline var bits: UInt8

        @inlinable init(bits: UInt8) {
            self.bits = bits
        }
    }
}
extension Phylum.Decl.Route: RawRepresentable {
    @inlinable public init?(rawValue: UInt8) {
        guard rawValue & 0b1111_1100 == 0 else {
            return nil
        }
        self.init(bits: rawValue)
    }

    @inlinable public var rawValue: UInt8 { self.bits }
}
extension Phylum.Decl.Route {
    @inlinable public init(underscored: Bool, hashed: Bool) {
        self.init(bits: 0)

        self.underscored = underscored
        self.hashed = hashed
    }
}
extension Phylum.Decl.Route {
    @inlinable public var underscored: Bool {
        get {
            self.bits & 0b0000_0010 != 0
        }
        set(value) {
            if  value {
                self.bits |= 0b0000_0010
            } else {
                self.bits &= 0b1111_1101
            }
        }
    }

    @inlinable public var hashed: Bool {
        get {
            self.bits & 0b0000_0001 != 0
        }
        set(value) {
            if  value {
                self.bits |= 0b0000_0001
            } else {
                self.bits &= 0b1111_1110
            }
        }
    }
}
