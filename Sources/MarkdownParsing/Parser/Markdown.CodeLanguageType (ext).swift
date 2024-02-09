import MarkdownABI
import MarkdownAST

extension Markdown.CodeLanguageType
{
    func attach(to code:String) -> MarkdownBlock
    {
        MarkdownBlock.Code<Self>.init(language: self, text: code)
    }
}
