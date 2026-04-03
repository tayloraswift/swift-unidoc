import JSON
import PackageGraphs
import Symbols

extension SPM.Manifest.Dependency {
    @frozen public struct Filesystem: Equatable, Sendable {
        public let identity: Symbol.Package
        public let location: Symbol.FileBase
        public let traits: [Trait]

        @inlinable public init(
            identity: Symbol.Package,
            location: Symbol.FileBase,
            traits: [Trait] = []
        ) {
            self.location = location
            self.identity = identity
            self.traits = traits
        }
    }
}
extension SPM.Manifest.Dependency.Filesystem: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case identity
        case location = "path"
        case traits
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        //  Note: location is not wrapped in a single-element array
        self.init(
            identity: try json[.identity].decode(),
            location: try json[.location].decode(),
            traits: try json[.traits]?.decode() ?? []
        )
    }
}
