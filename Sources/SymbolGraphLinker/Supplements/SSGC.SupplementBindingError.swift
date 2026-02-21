import LinkResolution
import SourceDiagnostics
import UCF

extension SSGC {
    struct SupplementBindingError: Error {
        let selector: UCF.Selector
        let variant: Variant

        init(selector: UCF.Selector, variant: Variant) {
            self.selector = selector
            self.variant = variant
        }
    }
}
extension SSGC.SupplementBindingError: Diagnostic {
    typealias Symbolicator = SSGC.Symbolicator

    func emit(summary output: inout DiagnosticOutput<SSGC.Symbolicator>) {
        switch self.variant {
        case .ambiguousBinding(let overloads, rejected: _):
            output[.error] = overloads.isEmpty ? """
            article binding '\(self.selector)' does not refer to any declarations
            """ : """
            article binding '\(self.selector)' is ambiguous
            """

        case .moduleNotAllowed(let module, expected: let expected):
            output[.error] = """
            article binding '\(self.selector)' cannot refer to a module ('\(module)') other
            than its own ('\(expected)')
            """

        case .vectorNotAllowed:
            output[.error] = """
            article binding '\(self.selector)' cannot refer to a vector symbol
            """
        }
    }

    func emit(details output: inout DiagnosticOutput<SSGC.Symbolicator>) {
        switch self.variant {
        case .ambiguousBinding(_, rejected: let rejected):
            for overload: any UCF.ResolvableOverload in rejected {
                let suggested: UCF.Selector = self.selector.with(hash: overload.traits.hash)

                output[.note] = """
                did you mean '\(suggested)'? (\(output.symbolicator.demangle(overload.id)))
                """
            }

        case .moduleNotAllowed:
            break

        case .vectorNotAllowed(let declaration, self: _):
            output[.note] = """
            did you mean to reference the inherited declaration? \
            (\(output.symbolicator[declaration]))
            """
        }
    }
}
