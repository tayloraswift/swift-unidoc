import UnidocRecords

extension Unidoc {
    enum StemComponentError: Error, Equatable, Sendable {
        case empty
    }
}
extension Unidoc.StemComponentError: CustomStringConvertible {
    var description: String {
        "stem cannot be empty"
    }
}
