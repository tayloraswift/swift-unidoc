extension SSGC.TypeChecker {
    struct AssertionError: Error {
        let message: String

        init(message: String) {
            self.message = message
        }
    }
}
extension SSGC.TypeChecker.AssertionError: CustomStringConvertible {
    var description: String { self.message }
}
