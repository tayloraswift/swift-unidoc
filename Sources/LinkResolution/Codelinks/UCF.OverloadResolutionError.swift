import UCF
import SourceDiagnostics

extension UCF
{
    @frozen public
    struct OverloadResolutionError<Symbolicator>:Error, Equatable
        where   Symbolicator:DiagnosticSymbolicator,
                Symbolicator.Address:Hashable,
                Symbolicator.Address:Sendable
    {
        public
        let overloads:[Overload<Symbolicator.Address>]
        public
        let selector:UCF.Selector

        @inlinable public
        init(overloads:[Overload<Symbolicator.Address>],
            selector:UCF.Selector)
        {
            self.overloads = overloads
            self.selector = selector
        }
    }
}
extension UCF.OverloadResolutionError:Diagnostic
{
    @inlinable public static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
    {
        if  self.overloads.isEmpty
        {
            output[.warning] += """
            selector '\(self.selector)' does not refer to any known declarations
            """
        }
        else
        {
            output[.warning] += """
            selector '\(self.selector)' is ambiguous
            """
        }
    }

    @inlinable public
    var notes:[Note]
    {
        self.overloads.map
        {
            .init(suggested: .init(
                    base: self.selector.base,
                    path: self.selector.path,
                    suffix: .hash($0.hash)),
                target: $0.target)
        }
    }
}
