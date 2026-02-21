extension SSGC {
    enum StatusStreamError: Equatable, Error {
        /// Distinguishes a broken pipe error that originates from a status stream from other
        /// broken pipe errors.
        case pipeDisconnected
    }
}
extension SSGC.StatusStreamError: CustomStringConvertible {
    var description: String {
        switch self {
        case .pipeDisconnected: "Status pipe disconnected"
        }
    }
}
