import MarkdownABI
import MarkdownRendering
import HTML
import Unidoc
import UnidocRecords

extension Inliner
{
    struct Passage
    {
        private
        let inliner:Inliner

        let bytecode:MarkdownBytecode
        let outlines:[Volume.Outline]

        init(_ inliner:Inliner, bytecode:MarkdownBytecode, outlines:[Volume.Outline])
        {
            self.inliner = inliner

            self.bytecode = bytecode
            self.outlines = outlines
        }
    }
}
extension Inliner.Passage:HyperTextRenderableMarkdown
{
    func load(_ reference:Int, for attribute:MarkdownBytecode.Attribute) -> String?
    {
        guard   case .href = attribute,
                self.outlines.indices.contains(reference)
        else
        {
            return nil
        }
        switch self.outlines[reference]
        {
        case .text(let text):
            return text

        case .path(_, let scalars):
            if  let target:Unidoc.Scalar = scalars.last
            {
                return self.inliner.url(target)
            }
            else
            {
                return nil
            }
        }
    }

    func load(_ reference:Int, into html:inout HTML.ContentEncoder)
    {
        guard self.outlines.indices.contains(reference)
        else
        {
            return
        }

        switch self.outlines[reference]
        {
        case .text(let text):
            html[.code] = text

        case .path(let stem, let scalars):
            //  Take the suffix of the stem, because it may include a module namespace,
            //  and we never render the module namespace, even if it was written in the
            //  codelink text.
            html[.code] = self.inliner.vectorLink(
                components: stem.split(separator: " ").suffix(scalars.count),
                to: scalars)
        }
    }
}
extension Inliner.Passage:PlainTextRenderableMarkdown
{
    func load(_ reference:Int, into utf8:inout [UInt8])
    {
        guard self.outlines.indices.contains(reference)
        else
        {
            return
        }
        switch self.outlines[reference]
        {
        case .text(let text):
            utf8 += text.utf8

        case .path(let stem, let scalars):
            let components:[Substring] = stem.split(separator: " ").suffix(scalars.count)
            var first:Bool = true
            for component:Substring in components
            {
                if  first
                {
                    first = false
                }
                else
                {
                    utf8.append(0x2E)
                }

                utf8 += component.utf8
            }
        }
    }
}
