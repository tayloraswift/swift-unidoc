import Sources

extension Diagnostics {
    @frozen @usableFromInline enum Group {
        case symbolic(
            any Diagnostic<Symbolicator>,
            context: DiagnosticContext<Symbolicator.Address>?
        )

        case literal(
            DiagnosticAlert,
            context: DiagnosticContext<Symbolicator.Address>?
        )
    }
}
