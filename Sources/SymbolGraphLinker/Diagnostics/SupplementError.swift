import Sources
import UnidocDiagnostics

enum SupplementError:Error, Equatable, Sendable
{
    case untitled            (SourceLocation<Int32>)
    case duplicate(id:String, SourceLocation<Int32>)
}
extension SupplementError
{
    private
    var location:SourceLocation<Int32>
    {
        switch self
        {
        case .untitled    (let location),
             .duplicate(_, let location):   return location
        }
    }
}
extension SupplementError:StaticLinkerError
{
    func symbolicated(with symbolicator:StaticSymbolicator) -> [Diagnostic]
    {
        let diagnostics:[Diagnostic]

        let location:Diagnostic.Context<Int32> = .init(location: self.location)
        let context:Diagnostic.Context<String> = location.symbolicated(with: symbolicator)

        switch self
        {
        case .untitled:
            diagnostics =
            [
                .init(.warning, context: context, message: "markdown supplement has no title"),
            ]
        case .duplicate(let id, _):
            diagnostics =
            [
                .init(.warning, context: context, message: """
                    markdown article cannot have the same file name ('\(id)') as another \
                    article in the same module
                    """),
            ]
        }

        return diagnostics
    }
}
