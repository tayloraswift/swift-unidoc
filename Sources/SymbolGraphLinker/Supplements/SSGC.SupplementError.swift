import SourceDiagnostics
import Sources

extension SSGC {
    enum SupplementError: Error, Equatable, Sendable {
        case multiple
        case untitled
        case untitledTutorial
        case extraBlocksInTutorial
    }
}
extension SSGC.SupplementError: Diagnostic {
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output: inout DiagnosticOutput<SSGC.Symbolicator>) {
        switch self {
        case .multiple:
            output[.error] = """
            markdown supplement extends a symbol that already has a supplement
            """

        case .untitled:
            output[.error] = """
            markdown supplement has no title
            """

        case .untitledTutorial:
            output[.error] = """
            markdown tutorial has no title
            """

        case .extraBlocksInTutorial:
            output[.error] = """
            markdown tutorial contains extra blocks
            """
        }
    }
}
