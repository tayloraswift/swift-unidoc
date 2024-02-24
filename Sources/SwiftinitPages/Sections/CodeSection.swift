import HTML
import MarkdownABI
import MarkdownRendering
import UnidocRecords

struct CodeSection
{
    let bytecode:Markdown.Bytecode
    private
    let scalars:[Unidoc.Scalar?]
    private
    let context:any Swiftinit.VertexPageContext

    init(_ context:any Swiftinit.VertexPageContext,
        bytecode:Markdown.Bytecode,
        scalars:[Unidoc.Scalar?])
    {
        self.bytecode = bytecode
        self.scalars = scalars
        self.context = context
    }
}
extension CodeSection:HTML.OutputStreamableMarkdown
{
    func load(_ reference:Int, for attribute:inout Markdown.Bytecode.Attribute) -> String?
    {
        switch attribute
        {
        case .href:
            if  self.scalars.indices.contains(reference),
                let target:Unidoc.Scalar = self.scalars[reference]
            {
                self.context[vertex: target]?.url
            }
            else
            {
                nil
            }

        case _:
            nil
        }
    }
}
