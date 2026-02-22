import Symbols

extension Unidoc {
    @frozen public struct VolumeSelector: Equatable, Hashable, Sendable {
        public var package: Symbol.Package
        public var version: Substring?

        @inlinable public init(package: Symbol.Package, version: Substring?) {
            self.package = package
            self.version = version
        }
    }
}
extension Unidoc.VolumeSelector: CustomStringConvertible {
    @inlinable public var description: String {
        self.version.map { "\(self.package):\($0)" } ?? "\(self.package)"
    }
}
extension Unidoc.VolumeSelector: LosslessStringConvertible {
    public init(_ trunk: String) {
        if  let colon: String.Index = trunk.firstIndex(of: ":") {
            self.init(
                package: .init(trunk[..<colon]),
                version: trunk[trunk.index(after: colon)...]
            )
        } else {
            self.init(
                package: .init(trunk),
                version: nil
            )
        }
    }
}
