import MarkdownABI
import MarkdownRendering
import HTML
import Unidoc
import UnidocRecords
import URI

extension Inliner
{
    struct Code
    {
        let bytecode:MarkdownBytecode
        private
        let scalars:[Unidoc.Scalar?]
        private
        let inliner:Inliner

        init(_ inliner:Inliner, bytecode:MarkdownBytecode, scalars:[Unidoc.Scalar?])
        {
            self.bytecode = bytecode
            self.scalars = scalars
            self.inliner = inliner
        }
    }
}
extension Inliner.Code:HyperTextRenderableMarkdown
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
