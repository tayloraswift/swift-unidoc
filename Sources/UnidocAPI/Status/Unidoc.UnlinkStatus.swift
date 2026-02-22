import Unidoc

extension Unidoc {
    @frozen public enum UnlinkStatus: Equatable, Sendable {
        /// The unlink request was declined, most likely because the volume is a release.
        case declined(Unidoc.Edition)
        /// The unlink request was successful.
        case unlinked(Unidoc.Edition)
    }
}
