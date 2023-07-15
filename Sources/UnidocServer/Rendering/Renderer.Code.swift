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
        let links:[Unidoc.Scalar?]

        init(_ renderer:Renderer, bytecode:MarkdownBytecode, links:[Unidoc.Scalar?] = [])
        {
            self.renderer = renderer
            self.bytecode = bytecode
            self.links = links
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
                self.links.indices.contains(index),
                let target:Unidoc.Scalar = self.links[index],
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
