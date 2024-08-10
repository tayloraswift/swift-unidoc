import UCF
import SourceDiagnostics
import UCF
import SourceDiagnostics

extension UCF
{
    @frozen public
    struct ResolutionError<Symbolicator>:Error where Symbolicator:DiagnosticSymbolicator
    {
        public
        let overloads:[any ResolvableOverload]
        public
        let rejected:[any ResolvableOverload]
        public
        let selector:UCF.Selector

        @inlinable public
        init(overloads:[any ResolvableOverload],
            rejected:[any ResolvableOverload],
            selector:UCF.Selector)
        {
            self.overloads = overloads
            self.rejected = rejected
            self.selector = selector
        }
    }
}
extension UCF.ResolutionError:Diagnostic
{
    @inlinable public
    func emit(summary:inout DiagnosticOutput<Symbolicator>)
    {
        summary[.warning] += self.overloads.isEmpty ? """
        selector '\(self.selector)' does not refer to any known declarations
        """ : """
        selector '\(self.selector)' is ambiguous
        """
    }

    @inlinable public
    func emit(details output:inout DiagnosticOutput<Symbolicator>)
    {
        for overload:any UCF.ResolvableOverload in [self.overloads, self.rejected].joined()
        {
            let suggested:UCF.Selector = .init(
                base: self.selector.base,
                path: self.selector.path,
                suffix: .hash(overload.hash))

            output[.note] = """
            did you mean '\(suggested)'? (\(output.symbolicator.demangle(overload.id)))
            """
        }
    }
}
