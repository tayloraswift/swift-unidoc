import SourceDiagnostics
import UCF

extension UCF {
    @frozen public struct ResolutionError<
        Symbolicator
    >: Error where Symbolicator: DiagnosticSymbolicator {
        public let overloads: [any ResolvableOverload]
        public let rejected: [any ResolvableOverload]
        public let selector: UCF.Selector

        @inlinable public init(
            overloads: [any ResolvableOverload],
            rejected: [any ResolvableOverload],
            selector: UCF.Selector
        ) {
            self.overloads = overloads
            self.rejected = rejected
            self.selector = selector
        }
    }
}
extension UCF.ResolutionError: Diagnostic {
    @inlinable public func emit(summary: inout DiagnosticOutput<Symbolicator>) {
        summary[.error] += self.overloads.isEmpty ? """
        selector '\(self.selector)' does not refer to any known declarations
        """ : """
        selector '\(self.selector)' is ambiguous
        """
    }

    @inlinable public func emit(details output: inout DiagnosticOutput<Symbolicator>) {
        let collisions: [UCF.Autograph: Int] = [self.overloads, self.rejected].joined().reduce(
            into: [:]
        ) {
            if  let autograph: UCF.Autograph = $1.traits.autograph {
                $0[autograph, default: 0] += 1
            }
        }

        for overload: any UCF.ResolvableOverload in [self.overloads, self.rejected].joined() {
            let traits: UCF.DisambiguationTraits = overload.traits
            let suffix: UCF.Selector.Suffix

            if  let autograph: UCF.Autograph = traits.autograph,
                case 1? = collisions[autograph] {
                suffix = .unidoc(
                    .init(
                        conditions: [],
                        signature: .function(autograph.inputs, autograph.output)
                    )
                )
            } else {
                suffix = .hash(traits.hash)
            }

            let suggested: UCF.Selector = .init(
                base: self.selector.base,
                path: self.selector.path,
                suffix: suffix
            )

            output[.note] = """
            did you mean '\(suggested)'? (\(output.symbolicator.demangle(overload.id)))
            """
        }
    }
}
