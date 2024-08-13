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
    @inlinable public
    func emit(summary:inout DiagnosticOutput<Symbolicator>)
    {
        if  self.overloads.isEmpty
        {
            summary[.warning] += """
            selector '\(self.selector)' does not refer to any known declarations
            """
        }
        else
        {
            summary[.warning] += """
            selector '\(self.selector)' is ambiguous
            """
        }
    }

    @inlinable public
    func emit(details:inout DiagnosticOutput<Symbolicator>)
    {
        for overload:UCF.Overload<Symbolicator.Address> in self.overloads
        {
            let suggested:UCF.Selector = .init(
                base: self.selector.base,
                path: self.selector.path,
                suffix: .hash(overload.hash))

            switch overload.target
            {
            case    .scalar(let scalar),
                    .vector(let scalar, self: _):
                details[.note] = """
                did you mean '\(suggested)'? (\(details.symbolicator[scalar]))
                """
            }
        }
    }
}
