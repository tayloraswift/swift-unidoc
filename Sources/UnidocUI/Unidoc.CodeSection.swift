import HTML
import MarkdownABI
import MarkdownRendering
import UnidocRecords

extension Unidoc
{
    struct CodeSection
    {
        let bytecode:Markdown.Bytecode
        private
        let scalars:[Unidoc.Scalar?]
        private
        let context:any VertexContext

        init(_ context:any VertexContext,
            bytecode:Markdown.Bytecode,
            scalars:[Unidoc.Scalar?])
        {
            self.bytecode = bytecode
            self.scalars = scalars
            self.context = context
        }
    }
}
extension Unidoc.CodeSection:HTML.OutputStreamableMarkdown
{
    func load(_ reference:Int, for type:inout Markdown.Bytecode.Attribute) -> String?
    {
        guard case .href = type
        else
        {
            return nil
        }

        if  self.scalars.indices.contains(reference),
            let target:Unidoc.Scalar = self.scalars[reference]
        {
            return self.context.load(id: target, href: &type)
        }
        else
        {
            return nil
        }
    }
}
