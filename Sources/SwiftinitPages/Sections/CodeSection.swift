import MarkdownABI
import MarkdownRendering
import HTML
import Unidoc
import UnidocRecords
import URI

struct CodeSection
{
    let bytecode:MarkdownBytecode
    private
    let scalars:[Unidoc.Scalar?]
    private
    let context:any Swiftinit.VersionedPageContext

    init(_ context:any Swiftinit.VersionedPageContext,
        bytecode:MarkdownBytecode,
        scalars:[Unidoc.Scalar?])
    {
        self.bytecode = bytecode
        self.scalars = scalars
        self.context = context
    }
}
extension CodeSection:HyperTextRenderableMarkdown
{
    func load(_ reference:Int, for attribute:MarkdownBytecode.Attribute) -> String?
    {
        switch attribute
        {
        case .href:
            if  self.scalars.indices.contains(reference),
                let target:Unidoc.Scalar = self.scalars[reference]
            {
                return self.context.url(target)
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
