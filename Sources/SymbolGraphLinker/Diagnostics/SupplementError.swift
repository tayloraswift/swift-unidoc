import Sources
import UnidocDiagnostics

enum SupplementError:Error, Equatable, Sendable
{
    case untitled(SourceLocation<Int32>)
}
extension SupplementError:StaticLinkerError
{
    func symbolicated(with symbolicator:StaticSymbolicator) -> [Diagnostic]
    {
        let diagnostics:[Diagnostic]

        switch self
        {
        case .untitled(let location):
            let location:Diagnostic.Context<Int32> = .init(location: location)
            let context:Diagnostic.Context<String> = location.symbolicated(with: symbolicator)
            diagnostics =
            [
                .init(.warning, context: context, message: "markdown supplement has no title"),
            ]
        }

        return diagnostics
    }
}
