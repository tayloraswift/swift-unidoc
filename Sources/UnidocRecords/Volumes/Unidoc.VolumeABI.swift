import SemanticVersions

extension Unidoc {
    @frozen public enum VolumeABI {
        @inlinable public static var version: MinorVersion { .v(1, 1) }
    }
}
