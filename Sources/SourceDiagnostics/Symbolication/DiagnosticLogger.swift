public protocol DiagnosticLogger: AnyObject {
    func emit(messages: consuming DiagnosticMessages) throws
}
