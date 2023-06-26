import CodelinkResolution
import Codelinks
import SymbolGraphs
import UnidocDiagnostics

struct InvalidArticleBindingError:Error
{
    let resolution:Resolution

    let codelink:Codelink
    let context:Diagnostic.Context<Int32>

    init(_ resolution:Resolution,
        codelink:Codelink,
        context:Diagnostic.Context<Int32>? = nil)
    {
        self.resolution = resolution
        self.codelink = codelink
        self.context = context ?? .init()
    }
}
extension InvalidArticleBindingError
{
    private
    var message:String
    {
        switch self.resolution
        {
        case .none(in: let culture):
            return """
                article binding '\(self.codelink)' does not refer to a declaration \
                in its module, \(culture)
                """

        case .vector:
            return """
                article binding '\(self.codelink)' cannot refer to a vector symbol
                """
        }
    }
}
extension InvalidArticleBindingError:StaticDiagnosis
{
    func symbolicated(with symbolicator:StaticSymbolicator) -> [Diagnostic]
    {
        let diagnostics:[Diagnostic]
        switch self.resolution
        {
        case .none(in: let culture):
            diagnostics =
            [
                .init(.warning, context: self.context.symbolicated(with: symbolicator),
                    message: """
                    article binding '\(self.codelink)' does not refer to a declaration \
                    in its module, \(culture)
                    """),
            ]

        case .vector(let feature, self: _):
            diagnostics =
            [
                .init(.warning, context: self.context.symbolicated(with: symbolicator),
                    message: """
                    article binding '\(self.codelink)' cannot refer to a vector symbol
                    """),

                .init(.note, message: """
                    did you mean to reference the protocol witness? \
                    (\(symbolicator.signature(of: feature)))
                    """)
            ]
        }
        return diagnostics
    }
}
