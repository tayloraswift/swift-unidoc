import Symbols

extension Unidoc {
    @frozen public struct UplinkStatus: Equatable, Sendable {
        public let edition: Edition
        public let volume: Symbol.Volume
        public let hiddenByPackage: Bool
        public let delta: SurfaceDelta?

        @inlinable public init(
            edition: Edition,
            volume: Symbol.Volume,
            hiddenByPackage: Bool,
            delta: SurfaceDelta?
        ) {
            self.edition = edition
            self.volume = volume
            self.hiddenByPackage = hiddenByPackage
            self.delta = delta
        }
    }
}
extension Unidoc.UplinkStatus {
    @inlinable public var hidden: Bool {
        if  self.hiddenByPackage {
            return true
        }

        switch self.delta {
        case nil:                   return true
        case .ignoredHistorical?:   return true
        case .ignoredPrivate?:      return true
        case .ignoredRepeated?:     return true
        case .initial?:             return false
        case .replaced?:            return false
        }
    }
}
