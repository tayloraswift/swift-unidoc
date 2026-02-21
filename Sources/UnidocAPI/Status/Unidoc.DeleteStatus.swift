import Unidoc

extension Unidoc {
    @frozen public enum DeleteStatus: Equatable, Sendable {
        /// The delete request was declined, most likely because the volume is a release.
        case declined(Unidoc.Edition)
        /// The delete request was successful.
        case deleted(Unidoc.Edition, fromS3: Bool)
    }
}
