import JSON
import PackageGraphs
import Symbols

extension SPM.Manifest.Dependency {
    @frozen public struct Filesystem: Equatable, Sendable {
        public let location: Symbol.FileBase
        public let identity: Symbol.Package

        @inlinable public init(identity: Symbol.Package, location: Symbol.FileBase) {
            self.location = location
            self.identity = identity
        }
    }
}
extension SPM.Manifest.Dependency.Filesystem: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case identity
        case location = "path"
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        //  Note: location is not wrapped in a single-element array
        self.init(
            identity: try json[.identity].decode(),
            location: try json[.location].decode()
        )
    }
}
