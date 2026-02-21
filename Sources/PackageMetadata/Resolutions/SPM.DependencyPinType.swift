import JSON

extension SPM {
    enum DependencyPinType: String, Hashable, Equatable, Sendable {
        case remoteSourceControl
        case localSourceControl
    }
}
extension SPM.DependencyPinType: JSONDecodable, JSONEncodable {
}
