import CodelinkResolution
import Codelinks
import SourceDiagnostics

@frozen public
struct InvalidCodelinkError<Symbolicator>:Error, Equatable
    where   Symbolicator:DiagnosticSymbolicator,
            Symbolicator.Address:Hashable,
            Symbolicator.Address:Sendable
{
    public
    let overloads:[CodelinkResolver<Symbolicator.Address>.Overload]
    public
    let codelink:Codelink

    @inlinable public
    init(overloads:[CodelinkResolver<Symbolicator.Address>.Overload],
        codelink:Codelink)
    {
        self.overloads = overloads
        self.codelink = codelink
    }
}
extension InvalidCodelinkError:Diagnostic
{
    @inlinable public static
    func += (output:inout DiagnosticOutput<Symbolicator>, self:Self)
    {
        if  self.overloads.isEmpty
        {
            output[.warning] += """
            codelink '\(self.codelink)' does not refer to any known declarations
            """
        }
        else
        {
            output[.warning] += """
            codelink '\(self.codelink)' is ambiguous
            """
        }
    }

    @inlinable public
    var notes:[Note]
    {
        self.overloads.map
        {
            .init(suggested: .init(
                    base: self.codelink.base,
                    path: self.codelink.path,
                    suffix: .hash($0.hash)),
                target: $0.target)
        }
    }
}
