import FNV1
import Symbols
import UnidocAPI

extension Unidoc {
    @frozen public struct Noun: Equatable, Sendable {
        public let shoot: Shoot
        public let type: NounType

        @inlinable public init(shoot: Shoot, type: NounType) {
            self.shoot = shoot
            self.type = type
        }
    }
}
extension Unidoc.Noun {
    @inlinable public var route: Unidoc.Route {
        .init(shoot: shoot, cdecl: type.decl?.cdecl ?? false)
    }
}
