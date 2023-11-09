import CodelinkResolution
import Codelinks
import SymbolGraphs
import UnidocDiagnostics

extension StaticLinker
{
    struct SupplementBindingError:Error
    {
        let resolved:SupplementBinding

        let codelink:Codelink
        let context:Diagnostic.Context<Int32>

        init(_ resolved:SupplementBinding,
            codelink:Codelink,
            context:Diagnostic.Context<Int32>? = nil)
        {
            self.resolved = resolved
            self.codelink = codelink
            self.context = context ?? .init()
        }
    }
}
extension StaticLinker.SupplementBindingError
{
    private
    var message:String
    {
        switch self.resolved
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
extension StaticLinker.SupplementBindingError:StaticLinkerError
{
    func symbolicated(with symbolicator:StaticSymbolicator) -> [Diagnostic]
    {
        let diagnostics:[Diagnostic]
        switch self.resolved
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
