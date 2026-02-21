import Sources

@frozen public struct Diagnostics<Symbolicator> where Symbolicator: DiagnosticSymbolicator {
    @usableFromInline internal var unsymbolicated: [Group]

    @inlinable internal init(unsymbolicated: [Group]) {
        self.unsymbolicated = unsymbolicated
    }
}
extension Diagnostics {
    @inlinable public init() {
        self.init(unsymbolicated: [])
    }
}
extension Diagnostics {
    public consuming func symbolicated(with symbolicator: Symbolicator) -> DiagnosticMessages {
        var output: DiagnosticOutput<Symbolicator> = .init(symbolicator: symbolicator)
        for group: Group in self.unsymbolicated {
            switch group {
            case .symbolic(let diagnostic, context: let context):
                output.append(diagnostic, with: context)

            case .literal(let alert, context: let context):
                output.append(alert, with: context)
            }
        }

        return .init(fragments: output.fragments)
    }
}
extension Diagnostics {
    @inlinable public var count: Int { self.unsymbolicated.count }

    @inlinable public static func += (self: inout Self, other: consuming Self) {
        self.unsymbolicated += other.unsymbolicated
    }
}
extension Diagnostics {
    @inlinable public subscript<Frame>(subject: SourceReference<Frame>?) -> DiagnosticAlert?
        where Frame: DiagnosticFrame<Symbolicator.Address> {
        get { nil }
        set (value) {
            guard
            let value: DiagnosticAlert else {
                return
            }

            self.unsymbolicated.append(
                .literal(
                    value,
                    context: subject.map(DiagnosticContext.around(_:))
                )
            )
        }
    }

    @inlinable public subscript(
        subject: SourceLocation<Symbolicator.Address>?
    ) -> DiagnosticAlert? {
        get { nil }
        set (value) {
            guard
            let value: DiagnosticAlert else {
                return
            }

            self.unsymbolicated.append(
                .literal(
                    value,
                    context: subject.map { .init(location: $0) }
                )
            )
        }
    }
}
extension Diagnostics {
    /// Emits a diagnostic pointing to the given source range. Contextual lines will be
    /// extracted if possible.
    @inlinable public subscript<Frame>(subject: SourceReference<Frame>?) -> (
        any Diagnostic<Symbolicator>
    )?
        where Frame: DiagnosticFrame<Symbolicator.Address> {
        get { nil }
        set (value) {
            guard
            let value: any Diagnostic<Symbolicator> else {
                return
            }

            self.unsymbolicated.append(
                .symbolic(
                    value,
                    context: subject.map(DiagnosticContext.around(_:))
                )
            )
        }
    }
    /// Emits a contextless diagnostic pointing to the given source location. If nil, the
    /// diagnostic will be emitted without a location.
    @inlinable public subscript(
        subject: SourceLocation<Symbolicator.Address>?
    ) -> (any Diagnostic<Symbolicator>)? {
        get { nil }
        set (value) {
            guard
            let value: any Diagnostic<Symbolicator> else {
                return
            }

            self.unsymbolicated.append(
                .symbolic(
                    value,
                    context: subject.map { .init(location: $0) }
                )
            )
        }
    }
}
