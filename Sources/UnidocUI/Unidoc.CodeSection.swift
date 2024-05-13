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
    func load(_ reference:Int, for attribute:inout Markdown.Bytecode.Attribute) -> String?
    {
        guard case .href = attribute
        else
        {
            return nil
        }

        guard self.scalars.indices.contains(reference),
        let target:Unidoc.Scalar = self.scalars[reference],
        let target:Unidoc.LinkTarget = self.context[vertex: target]?.target
        else
        {
            return nil
        }

        if  case .exported = target
        {
            attribute = .safelink
        }

        return target.url ?? "#"
    }
}
