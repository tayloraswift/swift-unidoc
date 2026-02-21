import FNV1
import SourceDiagnostics

extension SSGC {
    struct RouteCollisionError: Equatable, Error {
        let participants: [Int32]
        let path: Route
        let hash: FNV24?
        let redirect: Bool

        init(participants: [Int32], path: Route, hash: FNV24?, redirect: Bool = false) {
            self.participants = participants
            self.path = path
            self.hash = hash
            self.redirect = redirect
        }
    }
}
extension SSGC.RouteCollisionError: Diagnostic {
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output: inout DiagnosticOutput<Symbolicator>) {
        if  let hash: FNV24 = self.hash {
            output[.fatal] = """
            \(self.participants.count)-way hash collision on '\(self.path)'[\(hash)]
            """
        } else {
            output[.fatal] = """
            \(self.participants.count)-way path collision on '\(self.path)'
            """
        }
    }

    func emit(details output: inout DiagnosticOutput<Symbolicator>) {
        if  self.redirect {
            output[.note] = """
            collision occurs on @_exported redirect layer
            """
        }
        for participant: Int32 in self.participants {
            output[.note] = """
            vertex (\(output.symbolicator[participant])) does not have a unique URL
            """
        }
    }
}
