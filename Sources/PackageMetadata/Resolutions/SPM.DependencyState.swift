import JSON
import SemanticVersions
import SHA1

extension SPM {
    @frozen public struct DependencyState: Equatable, Hashable, Sendable {
        public let revision: SHA1
        public let version: AnyVersion

        @inlinable public init(revision: SHA1, version: AnyVersion) {
            self.revision = revision
            self.version = version
        }
    }
}
extension SPM.DependencyState: CustomStringConvertible {
    /// A *human-readable* description of this semantic ref name. This isn’t the
    /// same as its actual name (which is lost on parsing), and cannot be used to
    /// checkout a snapshot of the associated repository.
    public var description: String {
        switch self.version.canonical {
        case .stable(let version):
            "\(version) (stable, \(self.revision))"

        case .unstable(let name):
            "\(name) (unstable, \(self.revision))"
        }
    }
}
extension SPM.DependencyState: JSONObjectDecodable {
    public enum CodingKey: String, Sendable {
        case branch
        case revision
        case version
    }

    public init(json: JSON.ObjectDecoder<CodingKey>) throws {
        let version: AnyVersion
        //  `try?` because sometimes we have explicit JSON null
        if  let stable: SemanticVersion = try? json[.version]?.decode(
                as: JSON.StringRepresentation<SemanticVersion>.self,
                with: \.value
            ) {
            version = .stable(stable)
        } else {
            version = try json[.branch].decode(
                as: JSON.StringRepresentation<AnyVersion>.self,
                with: \.value
            )
        }
        self.init(revision: try json[.revision].decode(), version: version)
    }
}
