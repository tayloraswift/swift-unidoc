import CodelinkResolution
import Codelinks
import SymbolGraphs

struct AmbiguousCodelinkError:Error, Sendable
{
    let overloads:[CodelinkResolver<Int32>.Overload]
    let codelink:Codelink
    let context:StaticDiagnostic.Context<Int32>?

    init(overloads:[CodelinkResolver<Int32>.Overload],
        codelink:Codelink,
        context:StaticDiagnostic.Context<Int32>?)
    {
        self.overloads = overloads
        self.codelink = codelink
        self.context = context
    }
}
extension AmbiguousCodelinkError:StaticDiagnosis
{
    func symbolicated(with symbolicator:Symbolicator) -> [StaticDiagnostic]
    {
        [
            .init(.warning, context: self.context?.symbolicated(with: symbolicator),
                message: """
                codelink '\(self.codelink)' is ambiguous
                """)
        ]
        +
        self.overloads.map
        {
            let fixit:Codelink = .init(
                filter: self.codelink.filter,
                scope: self.codelink.scope,
                path: self.codelink.path,
                hash: $0.hash)
            switch $0.target
            {
            case    .scalar(let scalar),
                    .vector(let scalar, self: _):
                return .init(message: """
                    did you mean '\(fixit)'? (\(symbolicator(demangling: scalar)))
                    """)
            }
        }
    }
}
