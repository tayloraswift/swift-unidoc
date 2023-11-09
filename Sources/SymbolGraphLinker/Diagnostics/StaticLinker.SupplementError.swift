import Sources
import UnidocDiagnostics

extension StaticLinker
{
    enum SupplementError:Error, Equatable, Sendable
    {
        case implicitConcatenation(SourceLocation<Int32>?)
        case multiple(SourceLocation<Int32>)
        case untitled(SourceLocation<Int32>)
    }
}
extension StaticLinker.SupplementError:StaticLinkerError
{
    func symbolicated(with symbolicator:StaticSymbolicator) -> [Diagnostic]
    {
        let diagnostic:Diagnostic

        switch self
        {
        case .implicitConcatenation(let location):
            let location:Diagnostic.Context<Int32> = .init(location: location)
            let context:Diagnostic.Context<String> = location.symbolicated(with: symbolicator)

            diagnostic = .init(.warning,
                context: context,
                message: """
                markdown supplement extends a symbol that already has a documentation comment, \
                and no merge behavior was specified
                """)

        case .multiple(let location):
            let location:Diagnostic.Context<Int32> = .init(location: location)
            let context:Diagnostic.Context<String> = location.symbolicated(with: symbolicator)

            diagnostic = .init(.warning,
                context: context,
                message: "markdown supplement extends a symbol that already has a supplement")

        case .untitled(let location):
            let location:Diagnostic.Context<Int32> = .init(location: location)
            let context:Diagnostic.Context<String> = location.symbolicated(with: symbolicator)

            diagnostic = .init(.warning,
                context: context,
                message: "markdown supplement has no title")
        }

        return [diagnostic]
    }
}
