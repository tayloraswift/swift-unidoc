import MarkdownABI
import MarkdownRendering
import HTML
import Unidoc
import UnidocRecords
import URI

extension Renderer
{
    struct Code
    {
        let bytecode:MarkdownBytecode

        private
        let renderer:Renderer
        private
        let scalars:[Unidoc.Scalar?]

        init(_ renderer:Renderer, bytecode:MarkdownBytecode, scalars:[Unidoc.Scalar?] = [])
        {
            self.renderer = renderer
            self.bytecode = bytecode
            self.scalars = scalars
        }
    }
}
extension Renderer.Code:HyperTextRenderableMarkdown
{
    func load(_ reference:UInt32, for attribute:MarkdownBytecode.Attribute) -> String?
    {
        switch attribute
        {
        case .href:
            if  let index:Int = .init(exactly: reference),
                self.scalars.indices.contains(index),
                let target:Unidoc.Scalar = self.scalars[index],
                let uri:URI = self.renderer.uri(target)
            {
                return "\(uri)"
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
