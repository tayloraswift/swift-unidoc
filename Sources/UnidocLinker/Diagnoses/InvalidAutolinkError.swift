import MarkdownTrees
import SymbolGraphs

struct InvalidAutolinkError:Error, Sendable
{
    let autolink:MarkdownInline.Autolink
    let context:StaticDiagnostic.Context<Int32>?

    init(autolink:MarkdownInline.Autolink, context:StaticDiagnostic.Context<Int32>?)
    {
        self.autolink = autolink
        self.context = context
    }
}
extension InvalidAutolinkError:StaticDiagnosis
{
    func symbolicated(with symbolicator:Symbolicator) -> [StaticDiagnostic]
    {
        [
            .init(.warning, context: self.context?.symbolicated(with: symbolicator),
                message: """
                autolink expression '\(self.autolink.text)' could not be parsed
                """)
        ]
    }
}
