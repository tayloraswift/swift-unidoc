import Sources
import UnidocDiagnostics

extension StaticLinker
{
    @frozen public
    enum DuplicateSymbolError:Equatable, Error, Sendable
    {
        case article(id:String, SourceLocation<Int32>)
    }
}
extension StaticLinker.DuplicateSymbolError:StaticLinkerError
{
    public
    func symbolicated(with symbolicator:StaticSymbolicator) -> [Diagnostic]
    {
        let diagnostics:[Diagnostic]
        switch self
        {
        case .article(let id, let location):
            let location:Diagnostic.Context<Int32> = .init(location: location)
            let context:Diagnostic.Context<String> = location.symbolicated(with: symbolicator)
            diagnostics =
            [
                .init(.warning, context: context, message: """
                    markdown article cannot have the same mangled name ('\(id)') as another \
                    article in the same module
                    """),
            ]
        }
        return diagnostics
    }
}
