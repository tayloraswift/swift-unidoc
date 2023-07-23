import MarkdownABI
import MarkdownRendering
import HTML
import Unidoc
import UnidocRecords
import URI

struct DynamicCode
{
    let bytecode:MarkdownBytecode

    private
    let scalars:[Unidoc.Scalar?]
    private
    let inliner:Inliner

    init(bytecode:MarkdownBytecode, scalars:[Unidoc.Scalar?], inliner:Inliner)
    {
        self.bytecode = bytecode
        self.scalars = scalars
        self.inliner = inliner
    }
}
extension DynamicCode:HyperTextRenderableMarkdown
{
    func load(_ reference:Int, for attribute:MarkdownBytecode.Attribute) -> String?
    {
        switch attribute
        {
        case .href:
            if  self.scalars.indices.contains(reference),
                let target:Unidoc.Scalar = self.scalars[reference]
            {
                return self.inliner.uri(target)
            }
            else
            {
                return nil
            }

        case _:
            return nil
        }
    }
}
